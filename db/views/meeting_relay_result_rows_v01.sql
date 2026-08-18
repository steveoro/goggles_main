-- Flattened, read-only view collecting all displayable scalars for each
-- MeetingRelayResult (MRR), together with its relay swimmers and relay laps
-- aggregated as JSON. Designed to render whole meeting results pages with a
-- single query, filtered by meeting_id (predicate pushes down to the indexed
-- base tables).
-- NOTE: relay_laps_json is aggregated flat (one array per MRR) and carries
-- 'meeting_relay_swimmer_id' in each object so consumers can group laps by leg.
SELECT
  mrr.id AS meeting_relay_result_id,
  m.id AS meeting_id,
  ms.id AS meeting_session_id,
  ms.session_order,
  me.id AS meeting_event_id,
  me.event_order,
  et.id AS event_type_id,
  et.code AS event_type_code,
  mp.id AS meeting_program_id,
  mp.pool_type_id,
  ct.id AS category_type_id,
  ct.code AS category_code,
  ct.age_begin AS category_age_begin,
  mp.gender_type_id,
  gt.code AS gender_type_code,
  m.season_id,
  se.season_type_id,
  se.header_year AS season_header_year,
  mrr.rank,
  mrr.minutes,
  mrr.seconds,
  mrr.hundredths,
  (mrr.minutes * 6000 + mrr.seconds * 100 + mrr.hundredths) AS total_hundredths,
  mrr.reaction_time,
  mrr.standard_points,
  mrr.meeting_points,
  mrr.out_of_race,
  mrr.disqualified,
  mrr.disqualification_notes,
  mrr.relay_code,
  mrr.team_id,
  t.name AS team_name,
  t.editable_name AS team_editable_name,
  mrr.updated_at,
  mrr.meeting_relay_swimmers_count,
  (
    SELECT JSON_ARRAYAGG(
             JSON_OBJECT(
               'id', mrs.id,
               'relay_order', mrs.relay_order,
               'swimmer_id', mrs.swimmer_id,
               'swimmer_complete_name', sw.complete_name,
               'swimmer_year_of_birth', sw.year_of_birth,
               'badge_id', mrs.badge_id,
               'stroke_type_id', mrs.stroke_type_id,
               'length_in_meters', mrs.length_in_meters,
               'reaction_time', mrs.reaction_time,
               'minutes', mrs.minutes,
               'seconds', mrs.seconds,
               'hundredths', mrs.hundredths,
               'minutes_from_start', mrs.minutes_from_start,
               'seconds_from_start', mrs.seconds_from_start,
               'hundredths_from_start', mrs.hundredths_from_start,
               'relay_laps_count', mrs.relay_laps_count
             )
             ORDER BY mrs.relay_order
           )
    FROM meeting_relay_swimmers mrs
      LEFT JOIN swimmers sw ON sw.id = mrs.swimmer_id
    WHERE mrs.meeting_relay_result_id = mrr.id
  ) AS relay_swimmers_json,
  (
    SELECT JSON_ARRAYAGG(
             JSON_OBJECT(
               'id', rl.id,
               'meeting_relay_swimmer_id', rl.meeting_relay_swimmer_id,
               'swimmer_id', rl.swimmer_id,
               'length_in_meters', rl.length_in_meters,
               'minutes', rl.minutes,
               'seconds', rl.seconds,
               'hundredths', rl.hundredths,
               'minutes_from_start', rl.minutes_from_start,
               'seconds_from_start', rl.seconds_from_start,
               'hundredths_from_start', rl.hundredths_from_start,
               'reaction_time', rl.reaction_time,
               'position', rl.position
             )
             ORDER BY rl.length_in_meters
           )
    FROM relay_laps rl
    WHERE rl.meeting_relay_result_id = mrr.id
  ) AS relay_laps_json
FROM meeting_relay_results mrr
  JOIN meeting_programs mp ON mp.id = mrr.meeting_program_id
  JOIN meeting_events me ON me.id = mp.meeting_event_id
  JOIN meeting_sessions ms ON ms.id = me.meeting_session_id
  JOIN meetings m ON m.id = ms.meeting_id
  JOIN seasons se ON se.id = m.season_id
  JOIN event_types et ON et.id = me.event_type_id
  JOIN category_types ct ON ct.id = mp.category_type_id
  JOIN gender_types gt ON gt.id = mp.gender_type_id
  LEFT JOIN teams t ON t.id = mrr.team_id;

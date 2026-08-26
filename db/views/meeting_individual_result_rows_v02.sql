-- Flattened, read-only view collecting all displayable scalars for each
-- MeetingIndividualResult (MIR), together with its laps aggregated as JSON.
-- Designed to render whole meeting results pages with a single query,
-- filtered by meeting_id (predicate pushes down to the indexed base tables).
SELECT
  mir.id AS meeting_individual_result_id,
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
  mir.rank,
  mir.minutes,
  mir.seconds,
  mir.hundredths,
  (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) AS total_hundredths,
  mir.reaction_time,
  mir.standard_points,
  mir.meeting_points,
  mir.goggle_cup_points,
  mir.out_of_race,
  mir.disqualified,
  mir.disqualification_notes,
  mir.swimmer_id,
  sw.complete_name AS swimmer_complete_name,
  sw.year_of_birth AS swimmer_year_of_birth,
  sw.gender_type_id AS swimmer_gender_type_id,
  mir.team_id,
  t.name AS team_name,
  t.editable_name AS team_editable_name,
  mir.badge_id,
  mir.updated_at,
  (
    SELECT COUNT(l.id)
    FROM laps l
    WHERE l.meeting_individual_result_id = mir.id
  ) AS laps_count,
  (
    SELECT JSON_ARRAYAGG(
             JSON_OBJECT(
               'id', l.id,
               'length_in_meters', l.length_in_meters,
               'minutes', l.minutes,
               'seconds', l.seconds,
               'hundredths', l.hundredths,
               'minutes_from_start', l.minutes_from_start,
               'seconds_from_start', l.seconds_from_start,
               'hundredths_from_start', l.hundredths_from_start,
               'reaction_time', l.reaction_time,
               'position', l.position
             )
             ORDER BY l.length_in_meters
           )
    FROM laps l
    WHERE l.meeting_individual_result_id = mir.id
  ) AS laps_json
FROM meeting_individual_results mir
  JOIN meeting_programs mp ON mp.id = mir.meeting_program_id
  JOIN meeting_events me ON me.id = mp.meeting_event_id
  JOIN meeting_sessions ms ON ms.id = me.meeting_session_id
  JOIN meetings m ON m.id = ms.meeting_id
  JOIN seasons se ON se.id = m.season_id
  JOIN event_types et ON et.id = me.event_type_id
  JOIN category_types ct ON ct.id = mp.category_type_id
  JOIN gender_types gt ON gt.id = mp.gender_type_id
  JOIN swimmers sw ON sw.id = mir.swimmer_id
  LEFT JOIN teams t ON t.id = mir.team_id;

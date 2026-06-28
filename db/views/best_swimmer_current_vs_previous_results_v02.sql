-- CTE to get latest ongoing season (across any season type)
WITH CurrentSeason AS (
  SELECT s.id, s.begin_date
  FROM seasons s
  WHERE s.end_date >= CURRENT_DATE()
  ORDER BY s.begin_date DESC, s.id DESC
  LIMIT 1
),
-- CTE to get all previous seasons in the 1-year window before current season start
PreviousSeasons AS (
  SELECT s.id
  FROM seasons s
  JOIN CurrentSeason cs
    ON s.end_date < cs.begin_date
   AND s.end_date >= (cs.begin_date - INTERVAL 1 YEAR)
),
-- CTE collecting all valid MIRs for eligible event/pool domains
ValidResults AS (
  SELECT
    mir.swimmer_id,
    s.complete_name AS swimmer_name,
    s.year_of_birth AS swimmer_year_of_birth,
    s.gender_type_id,
    me.event_type_id,
    et.code AS event_type_code,
    mp.pool_type_id,
    pt.code AS pool_type_code,
    m.season_id,
    se.header_year AS season_header_year,
    mir.id AS meeting_individual_result_id,
    mir.minutes,
    mir.seconds,
    mir.hundredths,
    (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) AS total_hundredths,
    m.id AS meeting_id,
    m.header_date AS meeting_date,
    m.description AS meeting_name,
    t.id AS team_id,
    t.name AS team_name
  FROM meeting_individual_results mir
  JOIN meeting_programs mp ON mp.id = mir.meeting_program_id
  JOIN meeting_events me ON me.id = mp.meeting_event_id
  JOIN meeting_sessions ms ON ms.id = me.meeting_session_id
  JOIN meetings m ON m.id = ms.meeting_id
  JOIN seasons se ON se.id = m.season_id
  JOIN event_types et ON et.id = me.event_type_id
  JOIN pool_types pt ON pt.id = mp.pool_type_id
  JOIN swimmers s ON s.id = mir.swimmer_id
  JOIN teams t ON t.id = mir.team_id
  WHERE
    mir.disqualified = false
    AND (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) > 0
    AND me.event_type_id IN (2, 3, 4, 5, 6, 7, 11, 12, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24)
    AND mp.pool_type_id IN (1, 2)
),
-- Current season best result by swimmer/event/pool
CurrentSeasonRanked AS (
  SELECT
    vr.*,
    ROW_NUMBER() OVER (
      PARTITION BY vr.swimmer_id, vr.event_type_id, vr.pool_type_id
      ORDER BY vr.total_hundredths ASC, vr.meeting_date DESC, vr.meeting_id DESC
    ) AS rn
  FROM ValidResults vr
  JOIN CurrentSeason cs ON cs.id = vr.season_id
),
-- Previous window best result by swimmer/event/pool
PreviousSeasonRanked AS (
  SELECT
    vr.*,
    ROW_NUMBER() OVER (
      PARTITION BY vr.swimmer_id, vr.event_type_id, vr.pool_type_id
      ORDER BY vr.total_hundredths ASC, vr.meeting_date DESC, vr.meeting_id DESC
    ) AS rn
  FROM ValidResults vr
  JOIN PreviousSeasons ps ON ps.id = vr.season_id
),
CurrentBest AS (
  SELECT *
  FROM CurrentSeasonRanked
  WHERE rn = 1
),
PreviousBest AS (
  SELECT
    swimmer_id,
    event_type_id,
    pool_type_id,
    minutes AS old_minutes,
    seconds AS old_seconds,
    hundredths AS old_hundredths
  FROM PreviousSeasonRanked
  WHERE rn = 1
)
SELECT
  cb.swimmer_id,
  cb.swimmer_name,
  cb.swimmer_year_of_birth,
  cb.gender_type_id,
  cb.event_type_id,
  cb.event_type_code,
  cb.pool_type_id,
  cb.pool_type_code,
  cb.season_id,
  cb.season_header_year,
  cb.meeting_individual_result_id,
  cb.minutes,
  cb.seconds,
  cb.hundredths,
  cb.total_hundredths,
  cb.meeting_id,
  cb.meeting_date,
  cb.meeting_name,
  cb.team_id,
  cb.team_name,
  pb.old_minutes,
  pb.old_seconds,
  pb.old_hundredths
FROM CurrentBest cb
LEFT JOIN PreviousBest pb
  ON pb.swimmer_id = cb.swimmer_id
  AND pb.event_type_id = cb.event_type_id
  AND pb.pool_type_id = cb.pool_type_id;

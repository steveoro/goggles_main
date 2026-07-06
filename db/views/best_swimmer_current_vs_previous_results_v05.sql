-- CTE to compute championship year for each season based on begin_date/end_date
-- Sep-Dec start: championship_year = YEAR(begin_date)
-- Jun-Aug start: championship_year = YEAR(end_date)
-- Jan-May start: championship_year = YEAR(begin_date) - 1
WITH SeasonWithChampionship AS (
  SELECT s.id, s.begin_date, s.end_date,
    CASE
      WHEN MONTH(s.begin_date) >= 9 THEN YEAR(s.begin_date)
      WHEN MONTH(s.begin_date) <= 5 THEN YEAR(s.begin_date) - 1
      ELSE YEAR(s.end_date)
    END AS championship_year
  FROM seasons s
),
-- CTE to get the championship year of the latest ongoing season
CurrentChampionshipYear AS (
  SELECT swc.championship_year
  FROM SeasonWithChampionship swc
  WHERE swc.end_date >= CURRENT_DATE()
  ORDER BY swc.begin_date DESC, swc.id DESC
  LIMIT 1
),
-- CTE to get all seasons sharing the current championship year
CurrentSeasons AS (
  SELECT swc.id, swc.championship_year
  FROM SeasonWithChampionship swc
  JOIN CurrentChampionshipYear ccy ON swc.championship_year = ccy.championship_year
),
-- CTE to get all previous seasons with championship_year = current - 1
PreviousSeasons AS (
  SELECT swc.id
  FROM SeasonWithChampionship swc
  JOIN CurrentChampionshipYear ccy ON swc.championship_year = ccy.championship_year - 1
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
-- Current championship year best result by swimmer/event/pool
CurrentSeasonRanked AS (
  SELECT
    vr.*,
    ROW_NUMBER() OVER (
      PARTITION BY vr.swimmer_id, vr.event_type_id, vr.pool_type_id
      ORDER BY vr.total_hundredths ASC, vr.meeting_date DESC, vr.meeting_id DESC
    ) AS rn
  FROM ValidResults vr
  JOIN CurrentSeasons cs ON cs.id = vr.season_id
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
    meeting_individual_result_id AS old_meeting_individual_result_id,
    meeting_id AS old_meeting_id,
    meeting_date AS old_meeting_date,
    meeting_name AS old_meeting_name,
    total_hundredths AS old_total_hundredths,
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
  pb.old_meeting_individual_result_id,
  pb.old_meeting_id,
  pb.old_meeting_date,
  pb.old_meeting_name,
  pb.old_total_hundredths,
  pb.old_minutes,
  pb.old_seconds,
  pb.old_hundredths
FROM CurrentBest cb
LEFT JOIN PreviousBest pb
  ON pb.swimmer_id = cb.swimmer_id
  AND pb.event_type_id = cb.event_type_id
  AND pb.pool_type_id = cb.pool_type_id;

-- CTE to get the IDs of any season dating back at most 5 years ago
WITH RecentSeasons AS (
	SELECT id
	FROM seasons
	WHERE end_date >= (CURRENT_DATE() - INTERVAL 5 year)
	ORDER BY end_date DESC
),
-- CTE to rank the results within the desired seasons, events, and pools
RankedResults AS (
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
    t.name AS team_name,
    ROW_NUMBER() OVER (
      PARTITION BY mir.swimmer_id, me.event_type_id, mp.pool_type_id
      ORDER BY
        (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) ASC,
        m.header_date DESC
    ) as rn
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
  JOIN RecentSeasons rs ON m.season_id = rs.id
  WHERE
    mir.disqualified = false -- Corrected flag name
    AND (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) > 0 -- Ensure timing is positive
    AND me.event_type_id IN (2, 3, 11, 12, 15, 16, 19, 20, 22)
    AND mp.pool_type_id IN (1, 2)
)
-- Final selection of the best results
SELECT
  swimmer_id,
  swimmer_name,
  swimmer_year_of_birth,
  gender_type_id,
  event_type_id,
  event_type_code,
  pool_type_id,
  pool_type_code,
  season_id,
  season_header_year,
  meeting_individual_result_id,
  minutes,
  seconds,
  hundredths,
  total_hundredths,
  meeting_id,
  meeting_date,
  meeting_name,
  team_id,
  team_name
FROM RankedResults
WHERE rn = 1;

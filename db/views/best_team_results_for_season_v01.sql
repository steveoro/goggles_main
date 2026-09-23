-- CTE to rank, for each team & season, all individual results within each
-- supported "meeting program" tuple (event, category, gender, pool type).
-- Results are bound to the team through the swimmer's badge for that season
-- (a badge binds swimmer, team and season), so each tuple yields the single
-- best, non-zero, non-disqualified timing swum by *any* swimmer of that team.
WITH RankedResults AS (
  SELECT
    mir.swimmer_id,
    s.complete_name AS swimmer_name,
    s.year_of_birth AS swimmer_year_of_birth,
    mp.gender_type_id,
    gt.code AS gender_type_code,
    me.event_type_id,
    et.code AS event_type_code,
    mp.category_type_id,
    ct.code AS category_type_code,
    ct.short_name AS category_type_short_name,
    mp.pool_type_id,
    pt.code AS pool_type_code,
    m.season_id,
    se.header_year AS season_header_year,
    st.federation_type_id,
    mir.id AS meeting_individual_result_id,
    mir.minutes,
    mir.seconds,
    mir.hundredths,
    (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) AS total_hundredths,
    m.id AS meeting_id,
    m.header_date AS meeting_date,
    m.description AS meeting_name,
    b.team_id,
    t.name AS team_name,
    ROW_NUMBER() OVER (
      PARTITION BY b.team_id, m.season_id, me.event_type_id, mp.category_type_id, mp.gender_type_id, mp.pool_type_id
      ORDER BY
        (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) ASC,
        m.header_date DESC,
        m.id DESC
    ) as rn
  FROM meeting_individual_results mir
  JOIN badges b ON b.id = mir.badge_id
  JOIN meeting_programs mp ON mp.id = mir.meeting_program_id
  JOIN meeting_events me ON me.id = mp.meeting_event_id
  JOIN meeting_sessions ms ON ms.id = me.meeting_session_id
  JOIN meetings m ON m.id = ms.meeting_id
  JOIN seasons se ON se.id = m.season_id
  JOIN season_types st ON st.id = se.season_type_id
  JOIN event_types et ON et.id = me.event_type_id
  JOIN category_types ct ON ct.id = mp.category_type_id
  JOIN gender_types gt ON gt.id = mp.gender_type_id
  JOIN pool_types pt ON pt.id = mp.pool_type_id
  JOIN swimmers s ON s.id = mir.swimmer_id
  JOIN teams t ON t.id = b.team_id
  WHERE
    mir.disqualified = false
    AND (mir.minutes * 6000 + mir.seconds * 100 + mir.hundredths) > 0 -- Ensure timing is positive
    AND me.event_type_id IN (2, 3, 4, 5, 6, 7, 11, 12, 13, 15, 16, 17, 19, 20, 21, 22, 23, 24)
    AND mp.pool_type_id IN (1, 2)
    AND mp.gender_type_id IN (1, 2)
    AND b.season_id = m.season_id -- Ensure the badge belongs to the season of the result
)
-- Final selection of the best results (one row per team/season/program tuple;
-- tuples with no valid result simply yield no row)
SELECT
  swimmer_id,
  swimmer_name,
  swimmer_year_of_birth,
  gender_type_id,
  gender_type_code,
  event_type_id,
  event_type_code,
  category_type_id,
  category_type_code,
  category_type_short_name,
  pool_type_id,
  pool_type_code,
  season_id,
  season_header_year,
  federation_type_id,
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

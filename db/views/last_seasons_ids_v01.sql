-- *** All latest Season IDs, with & without MIRs & URs ***

-- [ MAS_FIN ] --
SELECT id FROM (
  SELECT id
    FROM seasons
    WHERE season_type_id = 1
    ORDER BY begin_date DESC LIMIT 1
) s1

UNION DISTINCT -- MAS_FIN with MIRs
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN meetings ON meetings.season_id = seasons.id
    INNER JOIN meeting_sessions ON meeting_sessions.meeting_id = meetings.id
    INNER JOIN meeting_events ON meeting_events.meeting_session_id = meeting_sessions.id
    INNER JOIN meeting_programs ON meeting_programs.meeting_event_id = meeting_events.id
    INNER JOIN meeting_individual_results ON meeting_individual_results.meeting_program_id = meeting_programs.id
    WHERE season_type_id = 1
    ORDER BY begin_date DESC LIMIT 1
) s1_1

UNION DISTINCT -- MAS_FIN with Workshops
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN user_workshops ON user_workshops.season_id = seasons.id
    WHERE season_type_id = 1
    ORDER BY begin_date DESC LIMIT 1
) s1_2

UNION DISTINCT -- MAS_FIN with URs
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN user_workshops ON user_workshops.season_id = seasons.id
    INNER JOIN user_results ON user_results.user_workshop_id = user_workshops.id
    WHERE season_type_id = 1
    ORDER BY begin_date DESC LIMIT 1
) s1_3


UNION DISTINCT


-- [ MAS_LEN ] --
SELECT id FROM (
  SELECT id
    FROM seasons
    WHERE season_type_id = 7
    ORDER BY begin_date DESC LIMIT 1
) s2

UNION DISTINCT -- MAS_LEN with MIRs
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN meetings ON meetings.season_id = seasons.id
    INNER JOIN meeting_sessions ON meeting_sessions.meeting_id = meetings.id
    INNER JOIN meeting_events ON meeting_events.meeting_session_id = meeting_sessions.id
    INNER JOIN meeting_programs ON meeting_programs.meeting_event_id = meeting_events.id
    INNER JOIN meeting_individual_results ON meeting_individual_results.meeting_program_id = meeting_programs.id
    WHERE season_type_id = 7
    ORDER BY begin_date DESC LIMIT 1
) s2_1

UNION DISTINCT -- MAS_LEN with Workshops
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN user_workshops ON user_workshops.season_id = seasons.id
    WHERE season_type_id = 7
    ORDER BY begin_date DESC LIMIT 1
) s2_2

UNION DISTINCT -- MAS_LEN with URs
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN user_workshops ON user_workshops.season_id = seasons.id
    INNER JOIN user_results ON user_results.user_workshop_id = user_workshops.id
    WHERE season_type_id = 7
    ORDER BY begin_date DESC LIMIT 1
) s2_3


UNION DISTINCT


-- [ MAS_FINA ] --
SELECT id FROM (
  SELECT id
    FROM seasons
    WHERE season_type_id = 8
    ORDER BY begin_date DESC LIMIT 1
) s3

UNION DISTINCT -- MAS_FINA with MIRs
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN meetings ON meetings.season_id = seasons.id
    INNER JOIN meeting_sessions ON meeting_sessions.meeting_id = meetings.id
    INNER JOIN meeting_events ON meeting_events.meeting_session_id = meeting_sessions.id
    INNER JOIN meeting_programs ON meeting_programs.meeting_event_id = meeting_events.id
    INNER JOIN meeting_individual_results ON meeting_individual_results.meeting_program_id = meeting_programs.id
    WHERE season_type_id = 8
    ORDER BY begin_date DESC LIMIT 1
) s3_1

UNION DISTINCT -- MAS_FINA with Workshops
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN user_workshops ON user_workshops.season_id = seasons.id
    WHERE season_type_id = 8
    ORDER BY begin_date DESC LIMIT 1
) s2_2

UNION DISTINCT -- MAS_FINA with URs
SELECT id FROM (
  SELECT seasons.id
    FROM seasons
    INNER JOIN user_workshops ON user_workshops.season_id = seasons.id
    INNER JOIN user_results ON user_results.user_workshop_id = user_workshops.id
    WHERE season_type_id = 8
    ORDER BY begin_date DESC LIMIT 1
) s2_3

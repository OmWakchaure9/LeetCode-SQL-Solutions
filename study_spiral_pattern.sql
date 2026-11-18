WITH NumberedSessions AS (
    SELECT
        session_id,
        student_id,
        subject,
        session_date,
        hours_studied,
        ROW_NUMBER() OVER (
            PARTITION BY student_id
            ORDER BY session_date, session_id
        ) AS rn,
        LAG(session_date) OVER (
            PARTITION BY student_id
            ORDER BY session_date, session_id
        ) AS previous_date
    FROM study_sessions
),

StudentStats AS (
    SELECT
        student_id,
        COUNT(*) AS total_sessions,
        COUNT(DISTINCT subject) AS cycle_length,
        SUM(hours_studied) AS total_study_hours,
        MAX(DATEDIFF(session_date, previous_date)) AS max_date_gap
    FROM NumberedSessions
    GROUP BY student_id
),

RepeatedPatterns AS (
    SELECT
        a.student_id
    FROM NumberedSessions a
    JOIN NumberedSessions b
        ON a.student_id = b.student_id
        AND b.rn = a.rn + (
            SELECT COUNT(DISTINCT s.subject)
            FROM study_sessions s
            WHERE s.student_id = a.student_id
        )
    JOIN StudentStats st
        ON a.student_id = st.student_id
    GROUP BY a.student_id, st.total_sessions, st.cycle_length
    HAVING
        COUNT(*) = st.total_sessions - st.cycle_length
        AND SUM(a.subject <> b.subject) = 0
)

SELECT
    s.student_id,
    s.student_name,
    s.major,
    st.cycle_length,
    st.total_study_hours
FROM StudentStats st
JOIN RepeatedPatterns rp
    ON st.student_id = rp.student_id
JOIN students s
    ON st.student_id = s.student_id
WHERE st.cycle_length >= 3
  AND st.total_sessions >= 2 * st.cycle_length
  AND st.max_date_gap <= 2
ORDER BY
    st.cycle_length DESC,
    st.total_study_hours DESC;

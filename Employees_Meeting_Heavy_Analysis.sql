WITH WeeklyMeetings AS (
    SELECT
        employee_id,
        YEARWEEK(meeting_date, 3) AS meeting_week,
        SUM(duration_hours) AS total_meeting_hours
    FROM meetings
    GROUP BY
        employee_id,
        YEARWEEK(meeting_date, 3)
),

MeetingHeavy AS (
    SELECT
        employee_id,
        COUNT(*) AS meeting_heavy_weeks
    FROM WeeklyMeetings
    WHERE total_meeting_hours > 20
    GROUP BY employee_id
    HAVING COUNT(*) >= 2
)

SELECT
    e.employee_id,
    e.employee_name,
    e.department,
    mh.meeting_heavy_weeks
FROM employees e
JOIN MeetingHeavy mh
    ON e.employee_id = mh.employee_id
ORDER BY
    mh.meeting_heavy_weeks DESC,
    e.employee_name ASC;

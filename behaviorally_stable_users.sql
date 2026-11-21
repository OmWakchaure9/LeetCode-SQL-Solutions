WITH daily AS (
    SELECT
        user_id,
        action_date,
        action,
        LAG(action) OVER (
            PARTITION BY user_id ORDER BY action_date
        ) AS prev_action,
        LAG(action_date) OVER (
            PARTITION BY user_id ORDER BY action_date
        ) AS prev_date
    FROM activity
),

grouped_data AS (
    SELECT
        user_id,
        action_date,
        action,
        SUM(
            CASE
                WHEN prev_action = action
                 AND DATEDIFF(action_date, prev_date) = 1
                THEN 0
                ELSE 1
            END
        ) OVER (
            PARTITION BY user_id
            ORDER BY action_date
        ) AS grp
    FROM daily
),

streaks AS (
    SELECT
        user_id,
        action,
        COUNT(*) AS streak_length,
        MIN(action_date) AS start_date,
        MAX(action_date) AS end_date
    FROM grouped_data
    GROUP BY user_id, action, grp
),

ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY
                streak_length DESC,
                action ASC,
                start_date DESC
        ) AS rn
    FROM streaks
    WHERE streak_length >= 5
)

SELECT
    user_id,
    action,
    streak_length,
    start_date,
    end_date
FROM ranked
WHERE rn = 1
ORDER BY streak_length DESC, user_id ASC;

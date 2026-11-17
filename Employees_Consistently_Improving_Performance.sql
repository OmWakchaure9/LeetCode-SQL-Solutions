WITH RankedReviews AS (
    SELECT
        employee_id,
        review_date,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn
    FROM performance_reviews
),

LastThree AS (
    SELECT
        employee_id,
        MAX(CASE WHEN rn = 1 THEN rating END) AS latest_rating,
        MAX(CASE WHEN rn = 2 THEN rating END) AS middle_rating,
        MAX(CASE WHEN rn = 3 THEN rating END) AS earliest_rating,
        COUNT(*) AS total_reviews
    FROM RankedReviews
    WHERE rn <= 3
    GROUP BY employee_id
)

SELECT
    e.employee_id,
    e.name,
    (l.latest_rating - l.earliest_rating) AS improvement_score
FROM LastThree l
JOIN employees e
    ON l.employee_id = e.employee_id
WHERE
    l.total_reviews = 3
    AND l.earliest_rating < l.middle_rating
    AND l.middle_rating < l.latest_rating
ORDER BY
    improvement_score DESC,
    e.name ASC;

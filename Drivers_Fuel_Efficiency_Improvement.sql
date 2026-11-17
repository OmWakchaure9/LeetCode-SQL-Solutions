WITH DriverEfficiency AS (
    SELECT
        driver_id,

        AVG(
            CASE
                WHEN MONTH(trip_date) BETWEEN 1 AND 6
                THEN distance_km / fuel_consumed
            END
        ) AS first_half_avg,

        AVG(
            CASE
                WHEN MONTH(trip_date) BETWEEN 7 AND 12
                THEN distance_km / fuel_consumed
            END
        ) AS second_half_avg

    FROM trips
    GROUP BY driver_id
)

SELECT
    d.driver_id,
    d.driver_name,
    ROUND(de.first_half_avg, 2) AS first_half_avg,
    ROUND(de.second_half_avg, 2) AS second_half_avg,
    ROUND(de.second_half_avg - de.first_half_avg, 2)
        AS efficiency_improvement

FROM drivers d
JOIN DriverEfficiency de
    ON d.driver_id = de.driver_id

WHERE
    de.first_half_avg IS NOT NULL
    AND de.second_half_avg IS NOT NULL
    AND de.second_half_avg > de.first_half_avg

ORDER BY
    efficiency_improvement DESC,
    d.driver_name ASC;

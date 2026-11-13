WITH RECURSIVE level_cte AS (
    -- Start with every employee
    SELECT
        employee_id,
        manager_id,
        1 AS level,
        salary
    FROM Employees

    UNION ALL

    -- Move upward through the management hierarchy
    SELECT
        lc.employee_id,
        e.manager_id,
        lc.level + 1,
        lc.salary
    FROM level_cte lc
    JOIN Employees e
        ON e.employee_id = lc.manager_id
),

employee_levels AS (
    -- Get the final hierarchy level for each employee
    SELECT
        employee_id,
        level
    FROM level_cte
    WHERE manager_id IS NULL
)

SELECT
    e.employee_id,
    e.employee_name,
    el.level,
    COALESCE(t.team_size, 0) AS team_size,
    e.salary + COALESCE(t.budget, 0) AS budget
FROM Employees e
JOIN employee_levels el
    ON e.employee_id = el.employee_id
LEFT JOIN (
    SELECT
        manager_id AS employee_id,
        COUNT(*) AS team_size,
        SUM(salary) AS budget
    FROM level_cte
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
) t
    ON e.employee_id = t.employee_id
ORDER BY
    el.level ASC,
    budget DESC,
    e.employee_name ASC;

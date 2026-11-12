WITH ExamDates AS (
    SELECT
        student_id,
        subject,
        MIN(exam_date) AS first_date,
        MAX(exam_date) AS latest_date
    FROM Scores
    GROUP BY student_id, subject
    HAVING COUNT(*) >= 2
)

SELECT
    e.student_id,
    e.subject,
    s1.score AS first_score,
    s2.score AS latest_score
FROM ExamDates e
JOIN Scores s1
    ON e.student_id = s1.student_id
    AND e.subject = s1.subject
    AND e.first_date = s1.exam_date
JOIN Scores s2
    ON e.student_id = s2.student_id
    AND e.subject = s2.subject
    AND e.latest_date = s2.exam_date
WHERE s2.score > s1.score
ORDER BY e.student_id, e.subject;

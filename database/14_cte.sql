PROMPT ==========================================
PROMPT CTE - DEPARTMENT STUDENT COUNTS
PROMPT ==========================================

WITH department_student_counts AS (
    SELECT
        department_id,
        COUNT(*) AS student_count
    FROM students
    GROUP BY department_id
)
SELECT
    d.department_id,
    d.department_name,
    NVL(dsc.student_count, 0) AS student_count
FROM departments d
LEFT JOIN department_student_counts dsc
    ON dsc.department_id = d.department_id
ORDER BY student_count DESC;

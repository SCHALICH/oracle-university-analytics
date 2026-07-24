/*
============================================================
File       : 15_subqueries.sql
Project    : Oracle University Analytics
Topic      : Subqueries
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100

COLUMN student_number FORMAT A15
COLUMN first_name FORMAT A15
COLUMN last_name FORMAT A15
COLUMN department_name FORMAT A45
COLUMN student_average FORMAT 990.99SET LINESIZE 200

PROMPT
PROMPT ============================================================
PROMPT SUBQUERIES
PROMPT ============================================================


-- ============================================================
-- 1. SCALAR SUBQUERY
-- Students whose average score is above the overall grade average
-- A scalar subquery returns exactly one value.
-- ============================================================

PROMPT
PROMPT 1. STUDENTS ABOVE THE OVERALL GRADE AVERAGE
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name,
    ROUND(get_student_average(s.student_id), 2) AS average_score
FROM students s
WHERE get_student_average(s.student_id) >
(
    SELECT AVG(g.score)
    FROM grades g
)
ORDER BY average_score DESC;


-- ============================================================
-- 2. MULTI-ROW SUBQUERY WITH IN
-- Students belonging to selected departments
-- IN can compare a value against multiple rows returned
-- by the inner query.
-- ============================================================

PROMPT
PROMPT 2. STUDENTS IN COMPUTER ENGINEERING OR MATHEMATICS
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name,
    s.department_id
FROM students s
WHERE s.department_id IN
(
    SELECT d.department_id
    FROM departments d
    WHERE d.department_name IN
    (
        'Computer Engineering',
        'Mathematics'
    )
)
ORDER BY s.department_id, s.student_number;


-- ============================================================
-- 3. EXISTS SUBQUERY
-- Students who have at least one grade
-- EXISTS checks whether at least one matching row exists.
-- ============================================================

PROMPT
PROMPT 3. STUDENTS WITH AT LEAST ONE GRADE
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name
FROM students s
WHERE EXISTS
(
    SELECT 1
    FROM enrollments e
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    WHERE e.student_id = s.student_id
)
ORDER BY s.student_number;


-- ============================================================
-- 4. NOT EXISTS SUBQUERY
-- Students who do not have any grades
-- NOT EXISTS returns rows for which no matching row exists.
-- ============================================================

PROMPT
PROMPT 4. STUDENTS WITHOUT ANY GRADES
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name
FROM students s
WHERE NOT EXISTS
(
    SELECT 1
    FROM enrollments e
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    WHERE e.student_id = s.student_id
)
ORDER BY s.student_number;


-- ============================================================
-- 5. CORRELATED SUBQUERY
-- Students whose average score is above their department average
-- The inner query references the outer query through
-- s.department_id.
-- ============================================================

PROMPT
PROMPT 5. STUDENTS ABOVE THEIR DEPARTMENT AVERAGE
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name,
    d.department_name,
    ROUND(get_student_average(s.student_id), 2) AS student_average
FROM students s
JOIN departments d
    ON d.department_id = s.department_id
WHERE get_student_average(s.student_id) >
(
    SELECT AVG(get_student_average(s2.student_id))
    FROM students s2
    WHERE s2.department_id = s.department_id
      AND get_student_average(s2.student_id) IS NOT NULL
)
ORDER BY d.department_name, student_average DESC;


PROMPT
PROMPT ============================================================
PROMPT END OF SUBQUERY EXAMPLES
PROMPT ============================================================

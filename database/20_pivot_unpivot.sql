/*
============================================================
File       : 20_pivot_unpivot.sql
Project    : Oracle University Analytics
Topic      : PIVOT / UNPIVOT
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET SQLBLANKLINES ON

COLUMN course_name FORMAT A45
COLUMN metric FORMAT A25
COLUMN item FORMAT A25

PROMPT
PROMPT ============================================================
PROMPT PIVOT / UNPIVOT EXAMPLES
PROMPT ============================================================


-- ============================================================
-- 1. PIVOT
-- Average score by department
-- ============================================================

PROMPT
PROMPT 1. PIVOT - AVERAGE SCORE BY DEPARTMENT
PROMPT ============================================================

SELECT *
FROM
(
    SELECT
        c.course_name,
        d.department_name,
        g.score
    FROM grades g
    JOIN enrollments e
        ON e.enrollment_id = g.enrollment_id
    JOIN course_offerings co
        ON co.offering_id = e.offering_id
    JOIN courses c
        ON c.course_id = co.course_id
    JOIN departments d
        ON d.department_id = c.department_id
)
PIVOT
(
    AVG(score)
    FOR department_name IN
    (
        'Computer Engineering' AS COMPUTER_ENGINEERING,
        'Mathematics' AS MATHEMATICS,
        'Electrical and Electronics Engineering' AS ELECTRICAL_ENGINEERING
    )
)
ORDER BY course_name;


-- ============================================================
-- 2. PIVOT
-- Enrollment count by department
-- ============================================================

PROMPT
PROMPT 2. PIVOT - ENROLLMENT COUNT
PROMPT ============================================================

SELECT *
FROM
(
    SELECT
        c.course_name,
        d.department_name,
        e.enrollment_id
    FROM enrollments e
    JOIN course_offerings co
        ON co.offering_id = e.offering_id
    JOIN courses c
        ON c.course_id = co.course_id
    JOIN departments d
        ON d.department_id = c.department_id
)
PIVOT
(
    COUNT(enrollment_id)
    FOR department_name IN
    (
        'Computer Engineering' AS COMPUTER_ENGINEERING,
        'Mathematics' AS MATHEMATICS,
        'Electrical and Electronics Engineering' AS ELECTRICAL_ENGINEERING
    )
)
ORDER BY course_name;


-- ============================================================
-- 3. UNPIVOT
-- Student statistics
-- ============================================================

PROMPT
PROMPT 3. UNPIVOT - STUDENT STATISTICS
PROMPT ============================================================

WITH report AS
(
    SELECT
        COUNT(*) total_students,
        COUNT(DISTINCT department_id) departments,
        COUNT(CASE WHEN status='ACTIVE' THEN 1 END) active_students
    FROM students
)

SELECT
    metric,
    value
FROM report
UNPIVOT
(
    value FOR metric IN
    (
        total_students,
        departments,
        active_students
    )
);


-- ============================================================
-- 4. PIVOT
-- Course status by department
-- ============================================================

PROMPT
PROMPT 4. PIVOT - COURSE STATUS
PROMPT ============================================================

SELECT *
FROM
(
    SELECT
        d.department_name,
        c.status AS course_status
    FROM courses c
    JOIN departments d
        ON d.department_id = c.department_id
)
PIVOT
(
    COUNT(course_status)
    FOR course_status IN
    (
        'ACTIVE' AS ACTIVE,
        'INACTIVE' AS INACTIVE
    )
)
ORDER BY department_name;


-- ============================================================
-- 5. UNPIVOT
-- Student summary
-- ============================================================

PROMPT
PROMPT 5. UNPIVOT - STUDENT SUMMARY
PROMPT ============================================================

WITH summary AS
(
    SELECT
        COUNT(*) students,
        COUNT(DISTINCT department_id) departments,
        MIN(enrollment_year) first_year,
        MAX(enrollment_year) last_year
    FROM students
)

SELECT
    item,
    value
FROM summary
UNPIVOT
(
    value FOR item IN
    (
        students,
        departments,
        first_year,
        last_year
    )
);

PROMPT
PROMPT ============================================================
PROMPT END OF PIVOT / UNPIVOT EXAMPLES
PROMPT ============================================================

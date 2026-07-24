/*
============================================================
File       : 17_advanced_grouping.sql
Project    : Oracle University Analytics
Topic      : Advanced Grouping
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET SQLBLANKLINES ON

COLUMN department_name FORMAT A45
COLUMN course_name FORMAT A40
COLUMN report_level FORMAT A25
COLUMN grouping_type FORMAT A25
COLUMN student_count FORMAT 999
COLUMN enrollment_count FORMAT 999
COLUMN average_score FORMAT 990.99
COLUMN department_grouped FORMAT 9
COLUMN course_grouped FORMAT 9
COLUMN grouping_id_value FORMAT 9

PROMPT
PROMPT ============================================================
PROMPT ADVANCED GROUPING
PROMPT ============================================================


-- ============================================================
-- 1. STANDARD GROUP BY
--
-- Counts students by department.
-- This is the baseline query before using advanced grouping.
-- ============================================================

PROMPT
PROMPT 1. GROUP BY - STUDENT COUNT BY DEPARTMENT
PROMPT ============================================================

SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM departments d
LEFT JOIN students s
    ON s.department_id = d.department_id
GROUP BY d.department_name
ORDER BY
    student_count DESC,
    d.department_name;


-- ============================================================
-- 2. ROLLUP
--
-- ROLLUP creates hierarchical subtotals and a grand total.
--
-- Grouping order:
-- department_name, course_name
--
-- Results:
-- 1. Department and course detail
-- 2. Department subtotal
-- 3. Grand total
-- ============================================================

PROMPT
PROMPT 2. ROLLUP - ENROLLMENT COUNT BY DEPARTMENT AND COURSE
PROMPT ============================================================

SELECT
    CASE
        WHEN GROUPING(d.department_name) = 1
            THEN 'GRAND TOTAL'
        ELSE d.department_name
    END AS department_name,
    CASE
        WHEN GROUPING(d.department_name) = 1
            THEN 'ALL COURSES'
        WHEN GROUPING(c.course_name) = 1
            THEN 'DEPARTMENT TOTAL'
        ELSE c.course_name
    END AS course_name,
    COUNT(e.enrollment_id) AS enrollment_count
FROM departments d
JOIN courses c
    ON c.department_id = d.department_id
LEFT JOIN course_offerings co
    ON co.course_id = c.course_id
LEFT JOIN enrollments e
    ON e.offering_id = co.offering_id
GROUP BY ROLLUP
(
    d.department_name,
    c.course_name
)
ORDER BY
    GROUPING(d.department_name),
    d.department_name,
    GROUPING(c.course_name),
    c.course_name;


-- ============================================================
-- 3. CUBE
--
-- CUBE generates every possible grouping combination.
--
-- For department_name and course_name:
-- 1. Department and course
-- 2. Department only
-- 3. Course only
-- 4. Grand total
-- ============================================================

PROMPT
PROMPT 3. CUBE - GRADE AVERAGE BY DEPARTMENT AND COURSE
PROMPT ============================================================

SELECT
    CASE
        WHEN GROUPING(d.department_name) = 1
            THEN 'ALL DEPARTMENTS'
        ELSE d.department_name
    END AS department_name,
    CASE
        WHEN GROUPING(c.course_name) = 1
            THEN 'ALL COURSES'
        ELSE c.course_name
    END AS course_name,
    ROUND(AVG(g.score), 2) AS average_score
FROM departments d
JOIN courses c
    ON c.department_id = d.department_id
JOIN course_offerings co
    ON co.course_id = c.course_id
JOIN enrollments e
    ON e.offering_id = co.offering_id
JOIN grades g
    ON g.enrollment_id = e.enrollment_id
GROUP BY CUBE
(
    d.department_name,
    c.course_name
)
ORDER BY
    GROUPING(d.department_name),
    d.department_name,
    GROUPING(c.course_name),
    c.course_name;


-- ============================================================
-- 4. GROUPING SETS
--
-- GROUPING SETS allows explicitly selected summary levels.
--
-- This query returns:
-- 1. Department-level totals
-- 2. Course-level totals
-- 3. Grand total
-- ============================================================

PROMPT
PROMPT 4. GROUPING SETS - SELECTED ENROLLMENT SUMMARY LEVELS
PROMPT ============================================================

SELECT
    CASE
        WHEN GROUPING(d.department_name) = 0
            THEN d.department_name
        ELSE 'ALL DEPARTMENTS'
    END AS department_name,
    CASE
        WHEN GROUPING(c.course_name) = 0
            THEN c.course_name
        ELSE 'ALL COURSES'
    END AS course_name,
    COUNT(e.enrollment_id) AS enrollment_count
FROM departments d
JOIN courses c
    ON c.department_id = d.department_id
LEFT JOIN course_offerings co
    ON co.course_id = c.course_id
LEFT JOIN enrollments e
    ON e.offering_id = co.offering_id
GROUP BY GROUPING SETS
(
    (d.department_name),
    (c.course_name),
    ()
)
ORDER BY
    GROUPING(d.department_name),
    d.department_name,
    GROUPING(c.course_name),
    c.course_name;


-- ============================================================
-- 5. GROUPING FUNCTION
--
-- GROUPING(column) returns:
-- 0 = Column is part of the current grouping level
-- 1 = Column is aggregated at the current grouping level
-- ============================================================

PROMPT
PROMPT 5. GROUPING FUNCTION - IDENTIFY REPORT LEVELS
PROMPT ============================================================

SELECT
    CASE
        WHEN GROUPING(d.department_name) = 1
         AND GROUPING(c.course_name) = 1
            THEN 'GRAND TOTAL'
        WHEN GROUPING(c.course_name) = 1
            THEN 'DEPARTMENT TOTAL'
        ELSE 'DETAIL'
    END AS report_level,
    CASE
        WHEN GROUPING(d.department_name) = 1
            THEN 'ALL DEPARTMENTS'
        ELSE d.department_name
    END AS department_name,
    CASE
        WHEN GROUPING(c.course_name) = 1
            THEN 'ALL COURSES'
        ELSE c.course_name
    END AS course_name,
    COUNT(e.enrollment_id) AS enrollment_count,
    GROUPING(d.department_name) AS department_grouped,
    GROUPING(c.course_name) AS course_grouped
FROM departments d
JOIN courses c
    ON c.department_id = d.department_id
LEFT JOIN course_offerings co
    ON co.course_id = c.course_id
LEFT JOIN enrollments e
    ON e.offering_id = co.offering_id
GROUP BY ROLLUP
(
    d.department_name,
    c.course_name
)
ORDER BY
    GROUPING(d.department_name),
    d.department_name,
    GROUPING(c.course_name),
    c.course_name;


-- ============================================================
-- 6. GROUPING_ID
--
-- GROUPING_ID returns a numeric identifier for each grouping
-- combination.
--
-- For two columns:
-- 0 = Department and course detail
-- 1 = Department subtotal
-- 2 = Course subtotal
-- 3 = Grand total
-- ============================================================

PROMPT
PROMPT 6. GROUPING_ID - CLASSIFY CUBE RESULTS
PROMPT ============================================================

SELECT
    GROUPING_ID
    (
        d.department_name,
        c.course_name
    ) AS grouping_id_value,
    CASE GROUPING_ID
    (
        d.department_name,
        c.course_name
    )
        WHEN 0 THEN 'DEPARTMENT AND COURSE'
        WHEN 1 THEN 'DEPARTMENT TOTAL'
        WHEN 2 THEN 'COURSE TOTAL'
        WHEN 3 THEN 'GRAND TOTAL'
    END AS grouping_type,
    CASE
        WHEN GROUPING(d.department_name) = 1
            THEN 'ALL DEPARTMENTS'
        ELSE d.department_name
    END AS department_name,
    CASE
        WHEN GROUPING(c.course_name) = 1
            THEN 'ALL COURSES'
        ELSE c.course_name
    END AS course_name,
    COUNT(e.enrollment_id) AS enrollment_count
FROM departments d
JOIN courses c
    ON c.department_id = d.department_id
LEFT JOIN course_offerings co
    ON co.course_id = c.course_id
LEFT JOIN enrollments e
    ON e.offering_id = co.offering_id
GROUP BY CUBE
(
    d.department_name,
    c.course_name
)
ORDER BY
    grouping_id_value,
    department_name,
    course_name;


PROMPT
PROMPT ============================================================
PROMPT END OF ADVANCED GROUPING EXAMPLES
PROMPT ============================================================

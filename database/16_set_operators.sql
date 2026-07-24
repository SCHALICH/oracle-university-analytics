/*
============================================================
File       : 16_set_operators.sql
Project    : Oracle University Analytics
Topic      : Set Operators
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 200
SET SQLBLANKLINES ON

COLUMN student_number FORMAT A15
COLUMN first_name FORMAT A15
COLUMN last_name FORMAT A15
COLUMN source_type FORMAT A20
COLUMN department_name FORMAT A45
COLUMN metric_name FORMAT A35
COLUMN metric_value FORMAT 999

PROMPT
PROMPT ============================================================
PROMPT SET OPERATORS
PROMPT ============================================================


-- ============================================================
-- 1. UNION
--
-- Combines two result sets and removes duplicate rows.
-- The queries must return the same number of columns with
-- compatible data types.
-- ============================================================

PROMPT
PROMPT 1. UNION - COMPUTER ENGINEERING AND MATHEMATICS STUDENTS
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name
FROM students s
JOIN departments d
    ON d.department_id = s.department_id
WHERE d.department_name = 'Computer Engineering'
UNION
SELECT
    s.student_number,
    s.first_name,
    s.last_name
FROM students s
JOIN departments d
    ON d.department_id = s.department_id
WHERE d.department_name = 'Mathematics'
ORDER BY student_number;


-- ============================================================
-- 2. UNION ALL
--
-- Combines result sets without removing duplicate rows.
-- A student may appear once as HAS ENROLLMENT and once as
-- HAS GRADE.
-- ============================================================

PROMPT
PROMPT 2. UNION ALL - STUDENT ACADEMIC ACTIVITY REPORT
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name,
    'HAS ENROLLMENT' AS source_type
FROM students s
WHERE EXISTS
(
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
)
UNION ALL
SELECT
    s.student_number,
    s.first_name,
    s.last_name,
    'HAS GRADE' AS source_type
FROM students s
WHERE EXISTS
(
    SELECT 1
    FROM enrollments e
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    WHERE e.student_id = s.student_id
)
ORDER BY student_number, source_type;


-- ============================================================
-- 3. INTERSECT
--
-- Returns rows that exist in both result sets.
-- This example finds students who:
--
-- 1. Belong to Computer Engineering or Mathematics
-- 2. Have at least one grade
-- ============================================================

PROMPT
PROMPT 3. INTERSECT - SELECTED DEPARTMENT STUDENTS WITH GRADES
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name
FROM students s
JOIN departments d
    ON d.department_id = s.department_id
WHERE d.department_name IN
(
    'Computer Engineering',
    'Mathematics'
)
INTERSECT
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
ORDER BY student_number;


-- ============================================================
-- 4. MINUS
--
-- Returns rows from the first query that do not exist in
-- the second query.
--
-- First query  : All students
-- Second query : Students with grades
-- Result       : Students without grades
-- ============================================================

PROMPT
PROMPT 4. MINUS - STUDENTS WITHOUT GRADES
PROMPT ============================================================

SELECT
    s.student_number,
    s.first_name,
    s.last_name
FROM students s
MINUS
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
ORDER BY student_number;


-- ============================================================
-- 5. UNION ALL SUMMARY REPORT
--
-- Combines several aggregate queries into one vertical report.
-- Literal values are used as report labels.
-- ============================================================

PROMPT
PROMPT 5. UNION ALL - ACADEMIC SUMMARY REPORT
PROMPT ============================================================

SELECT
    'TOTAL STUDENTS' AS metric_name,
    COUNT(*) AS metric_value
FROM students
UNION ALL
SELECT
    'STUDENTS WITH ENROLLMENTS' AS metric_name,
    COUNT(*) AS metric_value
FROM students s
WHERE EXISTS
(
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
)
UNION ALL
SELECT
    'STUDENTS WITH GRADES' AS metric_name,
    COUNT(*) AS metric_value
FROM students s
WHERE EXISTS
(
    SELECT 1
    FROM enrollments e
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    WHERE e.student_id = s.student_id
)
UNION ALL
SELECT
    'STUDENTS WITHOUT GRADES' AS metric_name,
    COUNT(*) AS metric_value
FROM students s
WHERE NOT EXISTS
(
    SELECT 1
    FROM enrollments e
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    WHERE e.student_id = s.student_id
);


PROMPT
PROMPT ============================================================
PROMPT END OF SET OPERATOR EXAMPLES
PROMPT ============================================================

/*
============================================================
File       : 18_window_ranking.sql
Project    : Oracle University Analytics
Topic      : Window Ranking Functions
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET SQLBLANKLINES ON

COLUMN s.student_name FORMAT A25
COLUMN department_name FORMAT A40
COLUMN course_name FORMAT A35
COLUMN score FORMAT 999.99

PROMPT
PROMPT ============================================================
PROMPT WINDOW RANKING FUNCTIONS
PROMPT ============================================================


-- ============================================================
-- 1. ROW_NUMBER()
-- ============================================================

PROMPT
PROMPT 1. ROW_NUMBER() - UNIQUE RANKING
PROMPT ============================================================

SELECT
    s.student_name,
    d.department_name,
    g.score,
    ROW_NUMBER() OVER (
        ORDER BY g.score DESC
    ) AS row_number
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
JOIN departments d
    ON d.department_id = s.department_id
ORDER BY g.score DESC;


-- ============================================================
-- 2. RANK()
-- ============================================================

PROMPT
PROMPT 2. RANK() - STANDARD RANKING
PROMPT ============================================================

SELECT
    s.student_name,
    d.department_name,
    g.score,
    RANK() OVER (
        ORDER BY g.score DESC
    ) AS student_rank
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
JOIN departments d
    ON d.department_id = s.department_id
ORDER BY g.score DESC;


-- ============================================================
-- 3. DENSE_RANK()
-- ============================================================

PROMPT
PROMPT 3. DENSE_RANK() - NO GAPS
PROMPT ============================================================

SELECT
    s.student_name,
    d.department_name,
    g.score,
    DENSE_RANK() OVER (
        ORDER BY g.score DESC
    ) AS dense_rank
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
JOIN departments d
    ON d.department_id = s.department_id
ORDER BY g.score DESC;


-- ============================================================
-- 4. ROW_NUMBER() PARTITION BY
-- ============================================================

PROMPT
PROMPT 4. TOP STUDENTS PER DEPARTMENT
PROMPT ============================================================

SELECT
    student_name,
    department_name,
    score,
    department_rank
FROM
(
    SELECT
        s.student_name,
        d.department_name,
        g.score,
        ROW_NUMBER() OVER
        (
            PARTITION BY d.department_name
            ORDER BY g.score DESC
        ) AS department_rank
    FROM grades g
    JOIN enrollments e
        ON e.enrollment_id = g.enrollment_id
    JOIN students s
        ON s.student_id = e.student_id
    JOIN departments d
        ON d.department_id = s.department_id
)
ORDER BY
    department_name,
    department_rank;


-- ============================================================
-- 5. RANK() PARTITION BY
-- ============================================================

PROMPT
PROMPT 5. RANK BY DEPARTMENT
PROMPT ============================================================

SELECT
    s.student_name,
    d.department_name,
    g.score,
    RANK() OVER
    (
        PARTITION BY d.department_name
        ORDER BY g.score DESC
    ) AS department_rank
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
JOIN departments d
    ON d.department_id = s.department_id
ORDER BY
    d.department_name,
    department_rank;


-- ============================================================
-- 6. NTILE()
-- ============================================================

PROMPT
PROMPT 6. NTILE(4) - QUARTILES
PROMPT ============================================================

SELECT
    s.student_name,
    g.score,
    NTILE(4) OVER
    (
        ORDER BY g.score DESC
    ) AS quartile
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
ORDER BY
    g.score DESC;


-- ============================================================
-- 7. PERCENT_RANK()
-- ============================================================

PROMPT
PROMPT 7. PERCENT_RANK()
PROMPT ============================================================

SELECT
    s.student_name,
    g.score,
    ROUND
    (
        PERCENT_RANK() OVER
        (
            ORDER BY g.score
        ),
        3
    ) AS percent_rank
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
ORDER BY
    g.score;


-- ============================================================
-- 8. CUME_DIST()
-- ============================================================

PROMPT
PROMPT 8. CUME_DIST()
PROMPT ============================================================

SELECT
    s.student_name,
    g.score,
    ROUND
    (
        CUME_DIST() OVER
        (
            ORDER BY g.score
        ),
        3
    ) AS cumulative_distribution
FROM grades g
JOIN enrollments e
    ON e.enrollment_id = g.enrollment_id
JOIN students s
    ON s.student_id = e.student_id
ORDER BY
    g.score;


PROMPT
PROMPT ============================================================
PROMPT END OF WINDOW RANKING EXAMPLES
PROMPT ============================================================

/*
============================================================
File       : 22_materialized_views.sql
Project    : Oracle University Analytics
Topic      : Materialized Views
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET SQLBLANKLINES ON

COLUMN department_name FORMAT A45
COLUMN mview_name FORMAT A30
COLUMN refresh_method FORMAT A20
COLUMN refresh_mode FORMAT A15

PROMPT
PROMPT ============================================================
PROMPT MATERIALIZED VIEW EXAMPLES
PROMPT ============================================================


-- ============================================================
-- CLEANUP
-- Existing materialized view is dropped before recreation
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW mv_student_summary';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -12003 AND SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/


-- ============================================================
-- 1. CREATE MATERIALIZED VIEW
-- Department-level student and grade summary
-- ============================================================

PROMPT
PROMPT 1. CREATE MATERIALIZED VIEW
PROMPT ============================================================

CREATE MATERIALIZED VIEW mv_student_summary
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    d.department_name,
    COUNT(DISTINCT s.student_id) AS total_students,
    ROUND(AVG(g.score), 2) AS average_score
FROM departments d
LEFT JOIN students s
    ON s.department_id = d.department_id
LEFT JOIN enrollments e
    ON e.student_id = s.student_id
LEFT JOIN grades g
    ON g.enrollment_id = e.enrollment_id
GROUP BY d.department_name;


-- ============================================================
-- 2. QUERY MATERIALIZED VIEW
-- ============================================================

PROMPT
PROMPT 2. QUERY MATERIALIZED VIEW
PROMPT ============================================================

SELECT
    department_name,
    total_students,
    average_score
FROM mv_student_summary
ORDER BY department_name;


-- ============================================================
-- 3. COMPARE WITH BASE QUERY
-- ============================================================

PROMPT
PROMPT 3. BASE QUERY
PROMPT ============================================================

SELECT
    d.department_name,
    COUNT(DISTINCT s.student_id) AS total_students,
    ROUND(AVG(g.score), 2) AS average_score
FROM departments d
LEFT JOIN students s
    ON s.department_id = d.department_id
LEFT JOIN enrollments e
    ON e.student_id = s.student_id
LEFT JOIN grades g
    ON g.enrollment_id = e.enrollment_id
GROUP BY d.department_name
ORDER BY d.department_name;


-- ============================================================
-- 4. REFRESH MATERIALIZED VIEW
-- COMPLETE refresh is executed manually
-- ============================================================

PROMPT
PROMPT 4. REFRESH MATERIALIZED VIEW
PROMPT ============================================================

BEGIN
    DBMS_MVIEW.REFRESH(
        list   => 'MV_STUDENT_SUMMARY',
        method => 'C'
    );
END;
/


-- ============================================================
-- 5. VERIFY REFRESHED DATA
-- ============================================================

PROMPT
PROMPT 5. VERIFY REFRESHED MATERIALIZED VIEW
PROMPT ============================================================

SELECT
    department_name,
    total_students,
    average_score
FROM mv_student_summary
ORDER BY department_name;


-- ============================================================
-- 6. MATERIALIZED VIEW METADATA
-- ============================================================

PROMPT
PROMPT 6. USER_MVIEWS
PROMPT ============================================================

SELECT
    mview_name,
    refresh_method,
    refresh_mode
FROM user_mviews
WHERE mview_name = 'MV_STUDENT_SUMMARY';


PROMPT
PROMPT ============================================================
PROMPT END OF MATERIALIZED VIEW EXAMPLES
PROMPT ============================================================

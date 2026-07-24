/*
============================================================
File       : 19_merge.sql
Project    : Oracle University Analytics
Topic      : MERGE Statement
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET SQLBLANKLINES ON

COLUMN student_name FORMAT A30
COLUMN department_name FORMAT A40

PROMPT
PROMPT ============================================================
PROMPT MERGE STATEMENT EXAMPLES
PROMPT ============================================================


-- ============================================================
-- DROP TABLE IF EXISTS
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE student_grade_summary';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

PROMPT
PROMPT SUMMARY TABLE CREATED
PROMPT ============================================================


CREATE TABLE student_grade_summary
(
    student_id      NUMBER PRIMARY KEY,
    student_name    VARCHAR2(120),
    department_name VARCHAR2(100),
    average_score   NUMBER(5,2),
    grade_count     NUMBER,
    updated_at      DATE
);


-- ============================================================
-- INITIAL MERGE
-- ============================================================

PROMPT
PROMPT INITIAL LOAD USING MERGE
PROMPT ============================================================

MERGE INTO student_grade_summary tgt
USING
(
    SELECT
        s.student_id,
        s.first_name || ' ' || s.last_name AS student_name,
        d.department_name,
        ROUND(AVG(g.score),2) AS average_score,
        COUNT(g.grade_id) AS grade_count
    FROM students s
    JOIN departments d
        ON d.department_id = s.department_id
    JOIN enrollments e
        ON e.student_id = s.student_id
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY
        s.student_id,
        s.first_name,
        s.last_name,
        d.department_name
) src
ON (tgt.student_id = src.student_id)

WHEN MATCHED THEN
UPDATE SET
    tgt.student_name    = src.student_name,
    tgt.department_name = src.department_name,
    tgt.average_score   = src.average_score,
    tgt.grade_count     = src.grade_count,
    tgt.updated_at      = SYSDATE

WHEN NOT MATCHED THEN
INSERT
(
    student_id,
    student_name,
    department_name,
    average_score,
    grade_count,
    updated_at
)
VALUES
(
    src.student_id,
    src.student_name,
    src.department_name,
    src.average_score,
    src.grade_count,
    SYSDATE
);

COMMIT;


PROMPT
PROMPT ============================================================
PROMPT SUMMARY TABLE CONTENT
PROMPT ============================================================

SELECT *
FROM student_grade_summary
ORDER BY average_score DESC;


-- ============================================================
-- DEMONSTRATE UPDATE
-- ============================================================

PROMPT
PROMPT UPDATE ONE ROW
PROMPT ============================================================

UPDATE student_grade_summary
SET average_score = average_score - 5;

COMMIT;


PROMPT
PROMPT AFTER MANUAL UPDATE
PROMPT ============================================================

SELECT
    student_name,
    average_score
FROM student_grade_summary
ORDER BY average_score DESC;


PROMPT
PROMPT ============================================================
PROMPT MERGE AGAIN (RESTORE VALUES)
PROMPT ============================================================

MERGE INTO student_grade_summary tgt
USING
(
    SELECT
        s.student_id,
        s.first_name || ' ' || s.last_name AS student_name,
        d.department_name,
        ROUND(AVG(g.score),2) average_score,
        COUNT(g.grade_id) grade_count
    FROM students s
    JOIN departments d
        ON d.department_id = s.department_id
    JOIN enrollments e
        ON e.student_id = s.student_id
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY
        s.student_id,
        s.first_name,
        s.last_name,
        d.department_name
) src
ON (tgt.student_id = src.student_id)

WHEN MATCHED THEN
UPDATE SET
    tgt.average_score = src.average_score,
    tgt.grade_count   = src.grade_count,
    tgt.updated_at    = SYSDATE;


COMMIT;


PROMPT
PROMPT ============================================================
PROMPT FINAL RESULT
PROMPT ============================================================

SELECT
    student_name,
    department_name,
    average_score,
    grade_count,
    updated_at
FROM student_grade_summary
ORDER BY average_score DESC;


PROMPT
PROMPT ============================================================
PROMPT END OF MERGE EXAMPLES
PROMPT ============================================================

/*
============================================================
File       : 21_json.sql
Project    : Oracle University Analytics
Topic      : JSON Functions
Database   : Oracle AI Database 26ai
============================================================
*/

SET PAGESIZE 200
SET LINESIZE 220
SET LONG 5000

PROMPT
PROMPT ============================================================
PROMPT JSON EXAMPLES
PROMPT ============================================================


-- ============================================================
-- 1. JSON_OBJECT
-- ============================================================

PROMPT
PROMPT 1. JSON_OBJECT
PROMPT ============================================================

SELECT
    JSON_OBJECT(
        'student_id' VALUE student_id,
        'student_number' VALUE student_number,
        'first_name' VALUE first_name,
        'last_name' VALUE last_name,
        'status' VALUE status
    ) AS student_json
FROM students
FETCH FIRST 5 ROWS ONLY;


-- ============================================================
-- 2. JSON_ARRAYAGG
-- ============================================================

PROMPT
PROMPT 2. JSON_ARRAYAGG
PROMPT ============================================================

SELECT
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'course' VALUE course_name
        )
    ) AS courses
FROM courses;


-- ============================================================
-- 3. JSON_OBJECTAGG
-- ============================================================

PROMPT
PROMPT 3. JSON_OBJECTAGG
PROMPT ============================================================

SELECT
    JSON_OBJECTAGG(
        department_name VALUE department_id
    ) AS departments
FROM departments;


-- ============================================================
-- 4. STUDENTS BY DEPARTMENT
-- ============================================================

PROMPT
PROMPT 4. JSON GROUPING
PROMPT ============================================================

SELECT
    d.department_name,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'student' VALUE s.first_name || ' ' || s.last_name,
            'number' VALUE s.student_number
        )
    ) AS students
FROM students s
JOIN departments d
    ON d.department_id = s.department_id
GROUP BY d.department_name
ORDER BY d.department_name;


-- ============================================================
-- 5. COURSE OFFERINGS
-- ============================================================

PROMPT
PROMPT 5. COURSE OFFERINGS AS JSON
PROMPT ============================================================

SELECT
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'course' VALUE c.course_name,
            'section' VALUE co.section_code,
            'classroom' VALUE co.classroom,
            'capacity' VALUE co.capacity
        )
    ) AS offerings
FROM course_offerings co
JOIN courses c
    ON c.course_id = co.course_id;


-- ============================================================
-- 6. ENROLLMENT SUMMARY
-- ============================================================

PROMPT
PROMPT 6. ENROLLMENT SUMMARY
PROMPT ============================================================

SELECT
    JSON_OBJECT(
        'students' VALUE (SELECT COUNT(*) FROM students),
        'courses' VALUE (SELECT COUNT(*) FROM courses),
        'offerings' VALUE (SELECT COUNT(*) FROM course_offerings),
        'enrollments' VALUE (SELECT COUNT(*) FROM enrollments)
    ) AS summary
FROM dual;


PROMPT
PROMPT ============================================================
PROMPT END OF JSON EXAMPLES
PROMPT ============================================================

/*
============================================================
File       : 23_xml.sql
Project    : Oracle University Analytics
Topic      : XML Functions
Database   : Oracle AI Database 26ai
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET LONG 5000
SET SQLBLANKLINES ON

COLUMN department_name FORMAT A40

PROMPT
PROMPT ============================================================
PROMPT XML EXAMPLES
PROMPT ============================================================


------------------------------------------------------------
-- 1. XMLELEMENT
------------------------------------------------------------

PROMPT
PROMPT 1. XMLELEMENT
PROMPT ============================================================

SELECT
    XMLELEMENT(
        "Student",
        XMLFOREST(
            student_id AS "StudentID",
            first_name AS "FirstName",
            last_name AS "LastName",
            student_number AS "StudentNumber"
        )
    ) AS student_xml
FROM students
FETCH FIRST 5 ROWS ONLY;


------------------------------------------------------------
-- 2. XMLFOREST
------------------------------------------------------------

PROMPT
PROMPT 2. XMLFOREST
PROMPT ============================================================

SELECT
    XMLFOREST(
        course_id AS "CourseID",
        course_name AS "CourseName",
        credits AS "Credits"
    ) AS course_xml
FROM courses;


------------------------------------------------------------
-- 3. XMLAGG
------------------------------------------------------------

PROMPT
PROMPT 3. XMLAGG
PROMPT ============================================================

SELECT
    XMLELEMENT(
        "Departments",
        XMLAGG(
            XMLELEMENT(
                "Department",
                XMLFOREST(
                    department_id AS "ID",
                    department_name AS "Name"
                )
            )
        )
    ) AS department_xml
FROM departments;


------------------------------------------------------------
-- 4. STUDENTS BY DEPARTMENT
------------------------------------------------------------

PROMPT
PROMPT 4. STUDENTS BY DEPARTMENT
PROMPT ============================================================

SELECT
    d.department_name,
    XMLELEMENT(
        "Students",
        XMLAGG(
            XMLELEMENT(
                "Student",
                XMLFOREST(
                    s.first_name || ' ' || s.last_name AS "Name",
                    s.student_number AS "Number"
                )
            )
        )
    ) AS xml_students
FROM students s
JOIN departments d
ON d.department_id = s.department_id
GROUP BY d.department_name
ORDER BY d.department_name;


------------------------------------------------------------
-- 5. XMLSERIALIZE
------------------------------------------------------------

PROMPT
PROMPT 5. XMLSERIALIZE
PROMPT ============================================================

SELECT
    XMLSERIALIZE(
        DOCUMENT
        XMLELEMENT(
            "Summary",
            XMLFOREST(
                (SELECT COUNT(*) FROM students) AS "Students",
                (SELECT COUNT(*) FROM departments) AS "Departments",
                (SELECT COUNT(*) FROM courses) AS "Courses",
                (SELECT COUNT(*) FROM enrollments) AS "Enrollments"
            )
        )
        AS CLOB INDENT SIZE = 2
    ) AS summary_xml
FROM dual;


PROMPT
PROMPT ============================================================
PROMPT END OF XML EXAMPLES
PROMPT ============================================================

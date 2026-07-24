/*
============================================================
File       : 25_final_reporting.sql
Project    : Oracle University Analytics
Topic      : Final Executive Reporting
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 200
SET LINESIZE 240
SET LONG 100000
SET LONGCHUNKSIZE 100000
SET SQLBLANKLINES ON
SET FEEDBACK ON
SET VERIFY OFF

COLUMN department_name FORMAT A45
COLUMN course_name FORMAT A45
COLUMN student_name FORMAT A30
COLUMN student_number FORMAT A15
COLUMN performance_level FORMAT A20
COLUMN score_band FORMAT A15
COLUMN report_json FORMAT A120
COLUMN report_xml FORMAT A120

PROMPT
PROMPT ============================================================
PROMPT ORACLE UNIVERSITY ANALYTICS
PROMPT FINAL EXECUTIVE REPORTING
PROMPT ============================================================


-- ============================================================
-- 1. EXECUTIVE SUMMARY
-- General university-level key performance indicators
-- ============================================================

PROMPT
PROMPT 1. EXECUTIVE SUMMARY
PROMPT ============================================================

WITH university_metrics AS
(
    SELECT
        (SELECT COUNT(*) FROM departments) AS total_departments,
        (SELECT COUNT(*) FROM courses) AS total_courses,
        (SELECT COUNT(*) FROM students) AS total_students,
        (SELECT COUNT(*) FROM course_offerings) AS total_offerings,
        (SELECT COUNT(*) FROM enrollments) AS total_enrollments,
        (SELECT COUNT(*) FROM grades) AS total_grades,
        (SELECT ROUND(AVG(score), 2) FROM grades) AS average_score
    FROM dual
)
SELECT
    total_departments,
    total_courses,
    total_students,
    total_offerings,
    total_enrollments,
    total_grades,
    average_score
FROM university_metrics;


-- ============================================================
-- 2. DEPARTMENT PERFORMANCE DASHBOARD
-- Student, course, enrollment and score metrics
-- ============================================================

PROMPT
PROMPT 2. DEPARTMENT PERFORMANCE DASHBOARD
PROMPT ============================================================

WITH department_students AS
(
    SELECT
        d.department_id,
        COUNT(s.student_id) AS total_students
    FROM departments d
    LEFT JOIN students s
        ON s.department_id = d.department_id
    GROUP BY d.department_id
),
department_courses AS
(
    SELECT
        d.department_id,
        COUNT(c.course_id) AS total_courses
    FROM departments d
    LEFT JOIN courses c
        ON c.department_id = d.department_id
    GROUP BY d.department_id
),
department_results AS
(
    SELECT
        d.department_id,
        COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
        ROUND(AVG(g.score), 2) AS average_score,
        MIN(g.score) AS minimum_score,
        MAX(g.score) AS maximum_score
    FROM departments d
    LEFT JOIN courses c
        ON c.department_id = d.department_id
    LEFT JOIN course_offerings co
        ON co.course_id = c.course_id
    LEFT JOIN enrollments e
        ON e.offering_id = co.offering_id
    LEFT JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY d.department_id
)
SELECT
    d.department_name,
    ds.total_students,
    dc.total_courses,
    dr.total_enrollments,
    dr.average_score,
    dr.minimum_score,
    dr.maximum_score,
    CASE
        WHEN dr.average_score IS NULL THEN 'NO GRADE DATA'
        WHEN dr.average_score >= 85 THEN 'EXCELLENT'
        WHEN dr.average_score >= 75 THEN 'GOOD'
        WHEN dr.average_score >= 65 THEN 'SATISFACTORY'
        ELSE 'NEEDS IMPROVEMENT'
    END AS performance_level
FROM departments d
JOIN department_students ds
    ON ds.department_id = d.department_id
JOIN department_courses dc
    ON dc.department_id = d.department_id
JOIN department_results dr
    ON dr.department_id = d.department_id
ORDER BY
    dr.average_score DESC NULLS LAST,
    d.department_name;


-- ============================================================
-- 3. DEPARTMENT RANKING
-- Analytic functions: RANK and university average comparison
-- ============================================================

PROMPT
PROMPT 3. DEPARTMENT RANKING
PROMPT ============================================================

WITH department_scores AS
(
    SELECT
        d.department_name,
        COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
        ROUND(AVG(g.score), 2) AS average_score
    FROM departments d
    LEFT JOIN courses c
        ON c.department_id = d.department_id
    LEFT JOIN course_offerings co
        ON co.course_id = c.course_id
    LEFT JOIN enrollments e
        ON e.offering_id = co.offering_id
    LEFT JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY d.department_name
)
SELECT
    department_name,
    total_enrollments,
    average_score,
    RANK() OVER (
        ORDER BY average_score DESC NULLS LAST
    ) AS department_rank,
    ROUND(
        AVG(average_score) OVER (),
        2
    ) AS university_department_average,
    ROUND(
        average_score - AVG(average_score) OVER (),
        2
    ) AS difference_from_average
FROM department_scores
ORDER BY department_rank, department_name;


-- ============================================================
-- 4. COURSE PERFORMANCE REPORT
-- Course-level capacity, enrollment and success metrics
-- ============================================================

PROMPT
PROMPT 4. COURSE PERFORMANCE REPORT
PROMPT ============================================================

WITH course_metrics AS
(
    SELECT
        c.course_id,
        c.course_name,
        c.credits,
        d.department_name,
        COUNT(DISTINCT co.offering_id) AS total_offerings,
        NVL(SUM(DISTINCT co.capacity), 0) AS total_capacity,
        COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
        ROUND(AVG(g.score), 2) AS average_score,
        MIN(g.score) AS minimum_score,
        MAX(g.score) AS maximum_score
    FROM courses c
    JOIN departments d
        ON d.department_id = c.department_id
    LEFT JOIN course_offerings co
        ON co.course_id = c.course_id
    LEFT JOIN enrollments e
        ON e.offering_id = co.offering_id
    LEFT JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY
        c.course_id,
        c.course_name,
        c.credits,
        d.department_name
)
SELECT
    department_name,
    course_name,
    credits,
    total_offerings,
    total_capacity,
    total_enrollments,
    CASE
        WHEN total_capacity = 0 THEN 0
        ELSE ROUND(total_enrollments / total_capacity * 100, 2)
    END AS capacity_utilization_pct,
    average_score,
    minimum_score,
    maximum_score
FROM course_metrics
ORDER BY
    department_name,
    average_score DESC NULLS LAST,
    course_name;


-- ============================================================
-- 5. STUDENT LEADERBOARD
-- Student averages, enrollment counts and ranking
-- ============================================================

PROMPT
PROMPT 5. STUDENT LEADERBOARD
PROMPT ============================================================

WITH student_performance AS
(
    SELECT
        s.student_id,
        s.student_number,
        s.first_name || ' ' || s.last_name AS student_name,
        d.department_name,
        COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
        COUNT(g.score) AS graded_courses,
        ROUND(AVG(g.score), 2) AS average_score
    FROM students s
    JOIN departments d
        ON d.department_id = s.department_id
    LEFT JOIN enrollments e
        ON e.student_id = s.student_id
    LEFT JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY
        s.student_id,
        s.student_number,
        s.first_name,
        s.last_name,
        d.department_name
)
SELECT
    student_number,
    student_name,
    department_name,
    total_enrollments,
    graded_courses,
    average_score,
    DENSE_RANK() OVER (
        ORDER BY average_score DESC NULLS LAST
    ) AS university_rank,
    DENSE_RANK() OVER (
        PARTITION BY department_name
        ORDER BY average_score DESC NULLS LAST
    ) AS department_rank
FROM student_performance
ORDER BY
    university_rank,
    student_name;


-- ============================================================
-- 6. TOP STUDENT IN EACH DEPARTMENT
-- CTE and ROW_NUMBER
-- ============================================================

PROMPT
PROMPT 6. TOP STUDENT IN EACH DEPARTMENT
PROMPT ============================================================

WITH student_scores AS
(
    SELECT
        s.student_id,
        s.student_number,
        s.first_name || ' ' || s.last_name AS student_name,
        d.department_name,
        COUNT(g.score) AS graded_courses,
        ROUND(AVG(g.score), 2) AS average_score
    FROM students s
    JOIN departments d
        ON d.department_id = s.department_id
    LEFT JOIN enrollments e
        ON e.student_id = s.student_id
    LEFT JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY
        s.student_id,
        s.student_number,
        s.first_name,
        s.last_name,
        d.department_name
),
ranked_students AS
(
    SELECT
        student_number,
        student_name,
        department_name,
        graded_courses,
        average_score,
        ROW_NUMBER() OVER
        (
            PARTITION BY department_name
            ORDER BY
                average_score DESC NULLS LAST,
                student_name
        ) AS row_num
    FROM student_scores
)
SELECT
    department_name,
    student_number,
    student_name,
    graded_courses,
    average_score
FROM ranked_students
WHERE row_num = 1
ORDER BY department_name;


-- ============================================================
-- 7. SCORE DISTRIBUTION
-- CASE-based score classification
-- ============================================================

PROMPT
PROMPT 7. SCORE DISTRIBUTION
PROMPT ============================================================

WITH score_classification AS
(
    SELECT
        CASE
            WHEN score >= 90 THEN '90-100'
            WHEN score >= 80 THEN '80-89'
            WHEN score >= 70 THEN '70-79'
            WHEN score >= 60 THEN '60-69'
            ELSE 'BELOW 60'
        END AS score_band,
        CASE
            WHEN score >= 90 THEN 1
            WHEN score >= 80 THEN 2
            WHEN score >= 70 THEN 3
            WHEN score >= 60 THEN 4
            ELSE 5
        END AS sort_order
    FROM grades
)
SELECT
    score_band,
    COUNT(*) AS grade_count,
    ROUND(
        COUNT(*) * 100 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM score_classification
GROUP BY score_band, sort_order
ORDER BY sort_order;


-- ============================================================
-- 8. DEPARTMENT SCORE PIVOT
-- Score bands displayed as columns
-- ============================================================

PROMPT
PROMPT 8. DEPARTMENT SCORE PIVOT
PROMPT ============================================================

SELECT
    department_name,
    NVL(excellent, 0) AS excellent,
    NVL(good, 0) AS good,
    NVL(satisfactory, 0) AS satisfactory,
    NVL(needs_improvement, 0) AS needs_improvement
FROM
(
    SELECT
        d.department_name,
        CASE
            WHEN g.score >= 85 THEN 'EXCELLENT'
            WHEN g.score >= 75 THEN 'GOOD'
            WHEN g.score >= 65 THEN 'SATISFACTORY'
            ELSE 'NEEDS_IMPROVEMENT'
        END AS score_category
    FROM departments d
    JOIN courses c
        ON c.department_id = d.department_id
    JOIN course_offerings co
        ON co.course_id = c.course_id
    JOIN enrollments e
        ON e.offering_id = co.offering_id
    JOIN grades g
        ON g.enrollment_id = e.enrollment_id
)
PIVOT
(
    COUNT(*)
    FOR score_category IN
    (
        'EXCELLENT' AS excellent,
        'GOOD' AS good,
        'SATISFACTORY' AS satisfactory,
        'NEEDS_IMPROVEMENT' AS needs_improvement
    )
)
ORDER BY department_name;


-- ============================================================
-- 9. ENROLLMENT SUMMARY WITH ROLLUP
-- Department and course subtotals
-- ============================================================

PROMPT
PROMPT 9. ENROLLMENT SUMMARY WITH ROLLUP
PROMPT ============================================================

SELECT
    CASE
        WHEN GROUPING(d.department_name) = 1
            THEN 'UNIVERSITY TOTAL'
        ELSE d.department_name
    END AS department_name,
    CASE
        WHEN GROUPING(c.course_name) = 1
            THEN 'DEPARTMENT TOTAL'
        ELSE c.course_name
    END AS course_name,
    COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
    ROUND(AVG(g.score), 2) AS average_score
FROM departments d
LEFT JOIN courses c
    ON c.department_id = d.department_id
LEFT JOIN course_offerings co
    ON co.course_id = c.course_id
LEFT JOIN enrollments e
    ON e.offering_id = co.offering_id
LEFT JOIN grades g
    ON g.enrollment_id = e.enrollment_id
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
-- 10. GROUPING SETS REPORT
-- Multiple aggregation levels in a single query
-- ============================================================

PROMPT
PROMPT 10. GROUPING SETS REPORT
PROMPT ============================================================

SELECT
    NVL(d.department_name, 'ALL DEPARTMENTS') AS department_name,
    NVL(c.course_name, 'ALL COURSES') AS course_name,
    COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
    ROUND(AVG(g.score), 2) AS average_score
FROM departments d
LEFT JOIN courses c
    ON c.department_id = d.department_id
LEFT JOIN course_offerings co
    ON co.course_id = c.course_id
LEFT JOIN enrollments e
    ON e.offering_id = co.offering_id
LEFT JOIN grades g
    ON g.enrollment_id = e.enrollment_id
GROUP BY GROUPING SETS
(
    (d.department_name, c.course_name),
    (d.department_name),
    ()
)
ORDER BY
    d.department_name NULLS LAST,
    c.course_name NULLS LAST;


-- ============================================================
-- 11. JSON EXECUTIVE REPORT
-- Machine-readable university summary
-- ============================================================

PROMPT
PROMPT 11. JSON EXECUTIVE REPORT
PROMPT ============================================================

SELECT
    JSON_OBJECT(
        'reportName' VALUE 'Oracle University Analytics',
        'generatedAt' VALUE TO_CHAR(
            SYSTIMESTAMP,
            'YYYY-MM-DD"T"HH24:MI:SS'
        ),
        'totalDepartments' VALUE (SELECT COUNT(*) FROM departments),
        'totalCourses' VALUE (SELECT COUNT(*) FROM courses),
        'totalStudents' VALUE (SELECT COUNT(*) FROM students),
        'totalEnrollments' VALUE (SELECT COUNT(*) FROM enrollments),
        'averageScore' VALUE (SELECT ROUND(AVG(score),2) FROM grades)
        RETURNING CLOB
    ) AS report_json
FROM dual;

-- ============================================================
-- 12. XML EXECUTIVE REPORT
-- XML-formatted university summary
-- ============================================================

PROMPT
PROMPT 12. XML EXECUTIVE REPORT
PROMPT ============================================================

SELECT XMLSERIALIZE
(
    DOCUMENT
    XMLELEMENT
    (
        "UniversityAnalytics",
        XMLFOREST
        (
            (SELECT COUNT(*) FROM departments)
                AS "TotalDepartments",

            (SELECT COUNT(*) FROM courses)
                AS "TotalCourses",

            (SELECT COUNT(*) FROM students)
                AS "TotalStudents",

            (SELECT COUNT(*) FROM enrollments)
                AS "TotalEnrollments",

            (SELECT ROUND(AVG(score), 2) FROM grades)
                AS "AverageScore"
        )
    )
    AS CLOB
    INDENT SIZE = 2
) AS report_xml
FROM dual;


-- ============================================================
-- 13. FINAL MANAGEMENT INSIGHTS
-- Rule-based observations for decision support
-- ============================================================

PROMPT
PROMPT 13. FINAL MANAGEMENT INSIGHTS
PROMPT ============================================================

WITH department_analysis AS
(
    SELECT
        d.department_name,
        COUNT(DISTINCT s.student_id) AS total_students,
        COUNT(DISTINCT c.course_id) AS total_courses,
        COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
        ROUND(AVG(g.score), 2) AS average_score
    FROM departments d
    LEFT JOIN students s
        ON s.department_id = d.department_id
    LEFT JOIN courses c
        ON c.department_id = d.department_id
    LEFT JOIN course_offerings co
        ON co.course_id = c.course_id
    LEFT JOIN enrollments e
        ON e.offering_id = co.offering_id
    LEFT JOIN grades g
        ON g.enrollment_id = e.enrollment_id
    GROUP BY d.department_name
)
SELECT
    department_name,
    total_students,
    total_courses,
    total_enrollments,
    average_score,
    CASE
        WHEN total_enrollments = 0
            THEN 'Increase course participation'

        WHEN average_score IS NULL
            THEN 'Collect and review grade data'

        WHEN average_score < 70
            THEN 'Review academic support requirements'

        WHEN average_score >= 85
            THEN 'Maintain high academic performance'

        ELSE
            'Monitor performance and enrollment trends'
    END AS management_recommendation
FROM department_analysis
ORDER BY
    average_score DESC NULLS LAST,
    department_name;


PROMPT
PROMPT ============================================================
PROMPT END OF FINAL EXECUTIVE REPORTING
PROMPT ============================================================

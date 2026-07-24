/*
============================================================
File       : 24_model_clause.sql
Project    : Oracle University Analytics
Topic      : MODEL Clause
Database   : Oracle AI Database 26ai
Author     : Cem
============================================================
*/

SET PAGESIZE 100
SET LINESIZE 220
SET SQLBLANKLINES ON

COLUMN department_name FORMAT A45
COLUMN scenario FORMAT A20
COLUMN course_name FORMAT A45

PROMPT
PROMPT ============================================================
PROMPT MODEL CLAUSE EXAMPLES
PROMPT ============================================================


-- ============================================================
-- 1. BASIC MODEL CLAUSE
-- ============================================================

PROMPT
PROMPT 1. BASIC MODEL CLAUSE
PROMPT ============================================================

SELECT
    department_name,
    current_students,
    projected_students
FROM
(
    SELECT
        d.department_name,
        COUNT(s.student_id) current_students,
        CAST(NULL AS NUMBER) projected_students
    FROM departments d
    LEFT JOIN students s
        ON s.department_id = d.department_id
    GROUP BY d.department_name
)
MODEL
    DIMENSION BY (department_name)
    MEASURES (
        current_students,
        projected_students
    )
    RULES
    (
        projected_students[ANY] =
            ROUND(current_students[CV()] * 1.10)
    )
ORDER BY department_name;


-- ============================================================
-- 2. MULTIPLE CALCULATED MEASURES
-- ============================================================

PROMPT
PROMPT 2. MULTIPLE CALCULATED MEASURES
PROMPT ============================================================

SELECT
    department_name,
    current_students,
    conservative_projection,
    optimistic_projection
FROM
(
    SELECT
        d.department_name,
        COUNT(s.student_id) current_students,
        CAST(NULL AS NUMBER) conservative_projection,
        CAST(NULL AS NUMBER) optimistic_projection
    FROM departments d
    LEFT JOIN students s
        ON s.department_id = d.department_id
    GROUP BY d.department_name
)
MODEL
    DIMENSION BY (department_name)
    MEASURES
    (
        current_students,
        conservative_projection,
        optimistic_projection
    )
    RULES
    (
        conservative_projection[ANY] =
            ROUND(current_students[CV()] * 1.05),

        optimistic_projection[ANY] =
            ROUND(current_students[CV()] * 1.20)
    )
ORDER BY department_name;


-- ============================================================
-- 3. SCORE ADJUSTMENT MODEL
-- ============================================================

PROMPT
PROMPT 3. SCORE ADJUSTMENT MODEL
PROMPT ============================================================

SELECT
    department_name,
    average_score,
    adjusted_score
FROM
(
    SELECT
        d.department_name,
        ROUND(AVG(g.score),2) average_score,
        CAST(NULL AS NUMBER) adjusted_score
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
MODEL
    DIMENSION BY (department_name)
    MEASURES
    (
        average_score,
        adjusted_score
    )
    RULES
    (
        adjusted_score[ANY] =
            CASE
                WHEN average_score[CV()] IS NULL THEN NULL
                WHEN average_score[CV()] < 70
                    THEN ROUND(average_score[CV()] + 5,2)
                WHEN average_score[CV()] < 85
                    THEN ROUND(average_score[CV()] + 3,2)
                ELSE average_score[CV()]
            END
    )
ORDER BY department_name;


-- ============================================================
-- 4. SCENARIO MODEL
-- ============================================================

PROMPT
PROMPT 4. SCENARIO MODEL
PROMPT ============================================================

SELECT
    department_name,
    scenario,
    student_count
FROM
(
    SELECT
        d.department_name,
        CAST('CURRENT' AS VARCHAR2(20)) scenario,
        COUNT(s.student_id) student_count
    FROM departments d
    LEFT JOIN students s
        ON s.department_id = d.department_id
    GROUP BY d.department_name
)
MODEL
    PARTITION BY (department_name)
    DIMENSION BY (scenario)
    MEASURES (student_count)
    RULES UPSERT
    (
        student_count['CONSERVATIVE'] =
            ROUND(student_count['CURRENT'] * 1.05),

        student_count['OPTIMISTIC'] =
            ROUND(student_count['CURRENT'] * 1.20)
    )
ORDER BY department_name, scenario;


-- ============================================================
-- 5. CAPACITY FORECAST MODEL
-- ============================================================

PROMPT
PROMPT 5. CAPACITY FORECAST MODEL
PROMPT ============================================================

SELECT
    course_name,
    current_capacity,
    next_year_capacity,
    two_year_capacity
FROM
(
    SELECT
        c.course_name,
        SUM(co.capacity) current_capacity,
        CAST(NULL AS NUMBER) next_year_capacity,
        CAST(NULL AS NUMBER) two_year_capacity
    FROM courses c
    LEFT JOIN course_offerings co
        ON co.course_id = c.course_id
    GROUP BY c.course_name
)
MODEL
    DIMENSION BY (course_name)
    MEASURES
    (
        current_capacity,
        next_year_capacity,
        two_year_capacity
    )
    RULES
    (
        next_year_capacity[ANY] =
            ROUND(NVL(current_capacity[CV()],0) * 1.10),

        two_year_capacity[ANY] =
            ROUND(NVL(next_year_capacity[CV()],0) * 1.10)
    )
ORDER BY course_name;


PROMPT
PROMPT ============================================================
PROMPT END OF MODEL CLAUSE EXAMPLES
PROMPT ============================================================

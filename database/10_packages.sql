CREATE OR REPLACE PACKAGE student_pkg AS

    PROCEDURE add_student (
        p_student_number   IN VARCHAR2,
        p_first_name       IN VARCHAR2,
        p_last_name        IN VARCHAR2,
        p_department_id    IN NUMBER,
        p_enrollment_year  IN NUMBER
    );

    FUNCTION get_student_average (
        p_student_id IN NUMBER
    ) RETURN NUMBER;

END student_pkg;
/

CREATE OR REPLACE PACKAGE BODY student_pkg AS

    PROCEDURE add_student (
        p_student_number   IN VARCHAR2,
        p_first_name       IN VARCHAR2,
        p_last_name        IN VARCHAR2,
        p_department_id    IN NUMBER,
        p_enrollment_year  IN NUMBER
    )
    AS
    BEGIN
        INSERT INTO students (
            student_number,
            first_name,
            last_name,
            department_id,
            enrollment_year
        )
        VALUES (
            p_student_number,
            p_first_name,
            p_last_name,
            p_department_id,
            p_enrollment_year
        );

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Bu ogrenci numarasi zaten kayitli.'
            );
    END add_student;


    FUNCTION get_student_average (
        p_student_id IN NUMBER
    )
    RETURN NUMBER
    AS
        v_avg NUMBER;
    BEGIN
        SELECT NVL(AVG(g.score), 0)
        INTO v_avg
        FROM grades g
        JOIN enrollments e
            ON e.enrollment_id = g.enrollment_id
        WHERE e.student_id = p_student_id;

        RETURN ROUND(v_avg, 2);
    END get_student_average;

END student_pkg;
/

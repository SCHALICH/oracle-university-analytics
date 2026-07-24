CREATE OR REPLACE PROCEDURE add_student (
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

    COMMIT;
END;
/

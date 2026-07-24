SET SERVEROUTPUT ON;

DECLARE
    CURSOR student_cursor IS
        SELECT
            student_number,
            first_name,
            last_name
        FROM students
        ORDER BY student_id;

    v_student_number students.student_number%TYPE;
    v_first_name     students.first_name%TYPE;
    v_last_name      students.last_name%TYPE;

BEGIN

    OPEN student_cursor;

    LOOP
        FETCH student_cursor
        INTO
            v_student_number,
            v_first_name,
            v_last_name;

        EXIT WHEN student_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            v_student_number || ' - ' ||
            v_first_name || ' ' ||
            v_last_name
        );

    END LOOP;

    CLOSE student_cursor;

END;
/

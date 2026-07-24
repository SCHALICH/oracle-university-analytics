SET SERVEROUTPUT ON;

BEGIN

    FOR student_rec IN (
        SELECT
            student_number,
            first_name,
            last_name
        FROM students
        ORDER BY student_id
    )
    LOOP

        DBMS_OUTPUT.PUT_LINE(
            student_rec.student_number || ' - ' ||
            student_rec.first_name || ' ' ||
            student_rec.last_name
        );

    END LOOP;

END;
/

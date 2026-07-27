SET SERVEROUTPUT ON

BEGIN
    FOR object_record IN (
        SELECT object_name, object_type
        FROM user_objects
        WHERE object_name IN (
            'STUDENT_PKG',
            'ADD_STUDENT',
            'TRG_STUDENTS_BI',
            'SEQ_STUDENTS',
            'VW_STUDENT_COURSES',
            'MV_STUDENT_SUMMARY',
            'STUDENT_GRADE_SUMMARY'
        )
        ORDER BY CASE object_type
            WHEN 'PACKAGE BODY' THEN 1
            WHEN 'PACKAGE' THEN 2
            WHEN 'PROCEDURE' THEN 3
            WHEN 'TRIGGER' THEN 4
            WHEN 'MATERIALIZED VIEW' THEN 5
            WHEN 'VIEW' THEN 6
            WHEN 'SEQUENCE' THEN 7
            WHEN 'TABLE' THEN 8
            ELSE 9
        END
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE
                'DROP ' || object_record.object_type || ' "' ||
                object_record.object_name || '"' ||
                CASE
                    WHEN object_record.object_type = 'TABLE'
                    THEN ' CASCADE CONSTRAINTS PURGE'
                    ELSE ''
                END;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(
                    'Could not drop ' || object_record.object_type || ' ' ||
                    object_record.object_name || ': ' || SQLERRM
                );
        END;
    END LOOP;
END;
/

BEGIN
    FOR table_record IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'GRADES',
            'EXAMS',
            'ENROLLMENTS',
            'COURSE_OFFERINGS',
            'SEMESTERS',
            'COURSES',
            'INSTRUCTORS',
            'STUDENTS',
            'DEPARTMENTS',
            'FACULTIES',
            'UNIVERSITIES'
        )
        ORDER BY CASE table_name
            WHEN 'GRADES' THEN 1
            WHEN 'EXAMS' THEN 2
            WHEN 'ENROLLMENTS' THEN 3
            WHEN 'COURSE_OFFERINGS' THEN 4
            WHEN 'SEMESTERS' THEN 5
            WHEN 'COURSES' THEN 6
            WHEN 'INSTRUCTORS' THEN 7
            WHEN 'STUDENTS' THEN 8
            WHEN 'DEPARTMENTS' THEN 9
            WHEN 'FACULTIES' THEN 10
            WHEN 'UNIVERSITIES' THEN 11
        END
    ) LOOP
        EXECUTE IMMEDIATE
            'DROP TABLE "' || table_record.table_name ||
            '" CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

PROMPT Project objects removed.

CREATE OR REPLACE TRIGGER trg_students_bi
BEFORE INSERT ON students
FOR EACH ROW
WHEN (NEW.student_id IS NULL)
BEGIN
    :NEW.student_id := seq_students.NEXTVAL;
END;
/

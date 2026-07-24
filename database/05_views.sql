CREATE OR REPLACE VIEW vw_student_courses AS
SELECT
    s.student_id,
    s.student_number,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_id,
    c.course_code,
    c.course_name,
    sem.semester_code,
    e.enrollment_date
FROM enrollments e
JOIN students s
    ON s.student_id = e.student_id
JOIN course_offerings co
    ON co.offering_id = e.offering_id
JOIN courses c
    ON c.course_id = co.course_id
JOIN semesters sem
    ON sem.semester_id = co.semester_id;

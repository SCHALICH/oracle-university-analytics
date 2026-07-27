CREATE INDEX ix_faculties_university
    ON faculties (university_id);

CREATE INDEX ix_departments_faculty
    ON departments (faculty_id);

CREATE INDEX ix_students_department
    ON students (department_id);

CREATE INDEX ix_students_name
    ON students (last_name, first_name);

CREATE INDEX ix_instructors_department
    ON instructors (department_id);

CREATE INDEX ix_courses_department
    ON courses (department_id);

CREATE INDEX ix_offerings_course
    ON course_offerings (course_id);

CREATE INDEX ix_offerings_instructor
    ON course_offerings (instructor_id);

CREATE INDEX ix_offerings_semester
    ON course_offerings (semester_id);

CREATE INDEX ix_enrollments_offering
    ON enrollments (offering_id);

CREATE INDEX ix_exams_offering
    ON exams (offering_id);

CREATE INDEX ix_grades_enrollment
    ON grades (enrollment_id);

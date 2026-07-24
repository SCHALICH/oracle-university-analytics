SET SQLBLANKLINES ON
SET DEFINE OFF

PROMPT Sample data loading started...

-- =========================================================
-- 1. UNIVERSITY
-- =========================================================

INSERT INTO universities (
    university_code,
    university_name,
    city,
    founded_year,
    website
)
VALUES (
    'ODTU',
    'Orta Dogu Teknik Universitesi',
    'Ankara',
    1956,
    'https://www.metu.edu.tr'
);


-- =========================================================
-- 2. FACULTIES
-- =========================================================

INSERT INTO faculties (
    university_id,
    faculty_code,
    faculty_name,
    dean_name,
    building_name,
    email
)
VALUES (
    (SELECT university_id
     FROM universities
     WHERE university_code = 'ODTU'),
    'ENG',
    'Faculty of Engineering',
    'Prof. Dr. Ahmet Yilmaz',
    'Engineering Central Building',
    'engineering@metu.edu.tr'
);

INSERT INTO faculties (
    university_id,
    faculty_code,
    faculty_name,
    dean_name,
    building_name,
    email
)
VALUES (
    (SELECT university_id
     FROM universities
     WHERE university_code = 'ODTU'),
    'SCI',
    'Faculty of Arts and Sciences',
    'Prof. Dr. Ayse Demir',
    'Science Building',
    'science@metu.edu.tr'
);


-- =========================================================
-- 3. DEPARTMENTS
-- =========================================================

INSERT INTO departments (
    faculty_id,
    department_code,
    department_name,
    head_name,
    email
)
VALUES (
    (SELECT faculty_id
     FROM faculties
     WHERE faculty_code = 'ENG'),
    'CENG',
    'Computer Engineering',
    'Prof. Dr. Mehmet Kaya',
    'ceng@metu.edu.tr'
);

INSERT INTO departments (
    faculty_id,
    department_code,
    department_name,
    head_name,
    email
)
VALUES (
    (SELECT faculty_id
     FROM faculties
     WHERE faculty_code = 'ENG'),
    'EE',
    'Electrical and Electronics Engineering',
    'Prof. Dr. Selin Aydin',
    'ee@metu.edu.tr'
);

INSERT INTO departments (
    faculty_id,
    department_code,
    department_name,
    head_name,
    email
)
VALUES (
    (SELECT faculty_id
     FROM faculties
     WHERE faculty_code = 'SCI'),
    'MATH',
    'Mathematics',
    'Prof. Dr. Murat Celik',
    'math@metu.edu.tr'
);

INSERT INTO departments (
    faculty_id,
    department_code,
    department_name,
    head_name,
    email
)
VALUES (
    (SELECT faculty_id
     FROM faculties
     WHERE faculty_code = 'SCI'),
    'STAT',
    'Statistics',
    'Prof. Dr. Zeynep Sahin',
    'stat@metu.edu.tr'
);


-- =========================================================
-- 4. STUDENTS
-- =========================================================

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    '20210001',
    'Ali',
    'Yildiz',
    'ali.yildiz@student.metu.edu.tr',
    DATE '2003-04-12',
    2021
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    '20210002',
    'Elif',
    'Kara',
    'elif.kara@student.metu.edu.tr',
    DATE '2002-11-03',
    2021
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    '20220003',
    'Can',
    'Demir',
    'can.demir@student.metu.edu.tr',
    DATE '2004-02-18',
    2022
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'EE'),
    '20210004',
    'Ece',
    'Aydin',
    'ece.aydin@student.metu.edu.tr',
    DATE '2003-07-25',
    2021
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'EE'),
    '20220005',
    'Burak',
    'Arslan',
    'burak.arslan@student.metu.edu.tr',
    DATE '2004-01-14',
    2022
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'MATH'),
    '20210006',
    'Derya',
    'Aksoy',
    'derya.aksoy@student.metu.edu.tr',
    DATE '2002-09-08',
    2021
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'MATH'),
    '20220007',
    'Emre',
    'Koc',
    'emre.koc@student.metu.edu.tr',
    DATE '2004-05-21',
    2022
);

INSERT INTO students (
    department_id,
    student_number,
    first_name,
    last_name,
    email,
    birth_date,
    enrollment_year
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'STAT'),
    '20220008',
    'Sude',
    'Yalcin',
    'sude.yalcin@student.metu.edu.tr',
    DATE '2003-12-17',
    2022
);


-- =========================================================
-- 5. INSTRUCTORS
-- =========================================================

INSERT INTO instructors (
    department_id,
    employee_number,
    first_name,
    last_name,
    academic_title,
    email,
    hire_date,
    salary
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    'EMP1001',
    'Mehmet',
    'Kaya',
    'PROFESSOR',
    'mehmet.kaya@metu.edu.tr',
    DATE '2010-09-01',
    95000
);

INSERT INTO instructors (
    department_id,
    employee_number,
    first_name,
    last_name,
    academic_title,
    email,
    hire_date,
    salary
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    'EMP1002',
    'Aylin',
    'Tekin',
    'ASSOCIATE PROFESSOR',
    'aylin.tekin@metu.edu.tr',
    DATE '2016-02-15',
    78000
);

INSERT INTO instructors (
    department_id,
    employee_number,
    first_name,
    last_name,
    academic_title,
    email,
    hire_date,
    salary
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'EE'),
    'EMP1003',
    'Selin',
    'Aydin',
    'PROFESSOR',
    'selin.aydin@metu.edu.tr',
    DATE '2008-09-01',
    98000
);

INSERT INTO instructors (
    department_id,
    employee_number,
    first_name,
    last_name,
    academic_title,
    email,
    hire_date,
    salary
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'MATH'),
    'EMP1004',
    'Murat',
    'Celik',
    'PROFESSOR',
    'murat.celik@metu.edu.tr',
    DATE '2012-01-20',
    90000
);


-- =========================================================
-- 6. COURSES
-- =========================================================

INSERT INTO courses (
    department_id,
    course_code,
    course_name,
    credits,
    course_level,
    description
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    'CENG101',
    'Introduction to Computer Engineering',
    4,
    1,
    'Fundamentals of programming and computer systems'
);

INSERT INTO courses (
    department_id,
    course_code,
    course_name,
    credits,
    course_level,
    description
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    'CENG213',
    'Data Structures',
    4,
    2,
    'Data structures, algorithms and complexity'
);

INSERT INTO courses (
    department_id,
    course_code,
    course_name,
    credits,
    course_level,
    description
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'CENG'),
    'CENG315',
    'Database Management Systems',
    4,
    3,
    'Relational databases, SQL and database design'
);

INSERT INTO courses (
    department_id,
    course_code,
    course_name,
    credits,
    course_level,
    description
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'EE'),
    'EE201',
    'Circuit Theory',
    4,
    2,
    'Analysis of electrical circuits'
);

INSERT INTO courses (
    department_id,
    course_code,
    course_name,
    credits,
    course_level,
    description
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'MATH'),
    'MATH153',
    'Calculus I',
    4,
    1,
    'Limits, derivatives and integrals'
);

INSERT INTO courses (
    department_id,
    course_code,
    course_name,
    credits,
    course_level,
    description
)
VALUES (
    (SELECT department_id FROM departments WHERE department_code = 'STAT'),
    'STAT201',
    'Probability and Statistics',
    3,
    2,
    'Probability distributions and statistical analysis'
);


-- =========================================================
-- 7. SEMESTER
-- =========================================================

INSERT INTO semesters (
    semester_code,
    academic_year,
    semester_name,
    start_date,
    end_date,
    status
)
VALUES (
    '2025-FALL',
    '2025-2026',
    'FALL',
    DATE '2025-09-22',
    DATE '2026-01-16',
    'COMPLETED'
);


-- =========================================================
-- 8. COURSE OFFERINGS
-- =========================================================

INSERT INTO course_offerings (
    course_id,
    instructor_id,
    semester_id,
    section_code,
    classroom,
    capacity,
    schedule_day,
    start_time,
    end_time
)
VALUES (
    (SELECT course_id FROM courses WHERE course_code = 'CENG101'),
    (SELECT instructor_id FROM instructors WHERE employee_number = 'EMP1001'),
    (SELECT semester_id FROM semesters WHERE semester_code = '2025-FALL'),
    '01',
    'BMB-1',
    40,
    'MONDAY',
    '09:00',
    '10:50'
);

INSERT INTO course_offerings (
    course_id,
    instructor_id,
    semester_id,
    section_code,
    classroom,
    capacity,
    schedule_day,
    start_time,
    end_time
)
VALUES (
    (SELECT course_id FROM courses WHERE course_code = 'CENG213'),
    (SELECT instructor_id FROM instructors WHERE employee_number = 'EMP1002'),
    (SELECT semester_id FROM semesters WHERE semester_code = '2025-FALL'),
    '01',
    'BMB-2',
    35,
    'TUESDAY',
    '11:00',
    '12:50'
);

INSERT INTO course_offerings (
    course_id,
    instructor_id,
    semester_id,
    section_code,
    classroom,
    capacity,
    schedule_day,
    start_time,
    end_time
)
VALUES (
    (SELECT course_id FROM courses WHERE course_code = 'CENG315'),
    (SELECT instructor_id FROM instructors WHERE employee_number = 'EMP1001'),
    (SELECT semester_id FROM semesters WHERE semester_code = '2025-FALL'),
    '01',
    'BMB-3',
    30,
    'WEDNESDAY',
    '14:00',
    '15:50'
);

INSERT INTO course_offerings (
    course_id,
    instructor_id,
    semester_id,
    section_code,
    classroom,
    capacity,
    schedule_day,
    start_time,
    end_time
)
VALUES (
    (SELECT course_id FROM courses WHERE course_code = 'EE201'),
    (SELECT instructor_id FROM instructors WHERE employee_number = 'EMP1003'),
    (SELECT semester_id FROM semesters WHERE semester_code = '2025-FALL'),
    '01',
    'EE-A1',
    40,
    'THURSDAY',
    '10:00',
    '11:50'
);

INSERT INTO course_offerings (
    course_id,
    instructor_id,
    semester_id,
    section_code,
    classroom,
    capacity,
    schedule_day,
    start_time,
    end_time
)
VALUES (
    (SELECT course_id FROM courses WHERE course_code = 'MATH153'),
    (SELECT instructor_id FROM instructors WHERE employee_number = 'EMP1004'),
    (SELECT semester_id FROM semesters WHERE semester_code = '2025-FALL'),
    '01',
    'MATH-101',
    60,
    'FRIDAY',
    '09:00',
    '10:50'
);


-- =========================================================
-- 9. ENROLLMENTS
-- =========================================================

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20210001'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG315'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20210002'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG315'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20220003'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG213'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20210001'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG213'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20210002'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'MATH153'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20210004'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'EE201'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20220005'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'EE201'
       AND co.section_code = '01')
);

INSERT INTO enrollments (student_id, offering_id)
VALUES (
    (SELECT student_id FROM students WHERE student_number = '20210006'),
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'MATH153'
       AND co.section_code = '01')
);


-- =========================================================
-- 10. EXAMS
-- =========================================================

INSERT INTO exams (
    offering_id,
    exam_name,
    exam_type,
    exam_date,
    maximum_score,
    weight_percentage
)
VALUES (
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG315'
       AND co.section_code = '01'),
    'Database Midterm',
    'MIDTERM',
    DATE '2025-11-10',
    100,
    40
);

INSERT INTO exams (
    offering_id,
    exam_name,
    exam_type,
    exam_date,
    maximum_score,
    weight_percentage
)
VALUES (
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG315'
       AND co.section_code = '01'),
    'Database Final',
    'FINAL',
    DATE '2026-01-08',
    100,
    60
);

INSERT INTO exams (
    offering_id,
    exam_name,
    exam_type,
    exam_date,
    maximum_score,
    weight_percentage
)
VALUES (
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG213'
       AND co.section_code = '01'),
    'Data Structures Midterm',
    'MIDTERM',
    DATE '2025-11-12',
    100,
    40
);

INSERT INTO exams (
    offering_id,
    exam_name,
    exam_type,
    exam_date,
    maximum_score,
    weight_percentage
)
VALUES (
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'CENG213'
       AND co.section_code = '01'),
    'Data Structures Final',
    'FINAL',
    DATE '2026-01-10',
    100,
    60
);

INSERT INTO exams (
    offering_id,
    exam_name,
    exam_type,
    exam_date,
    maximum_score,
    weight_percentage
)
VALUES (
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'EE201'
       AND co.section_code = '01'),
    'Circuit Theory Final',
    'FINAL',
    DATE '2026-01-09',
    100,
    100
);

INSERT INTO exams (
    offering_id,
    exam_name,
    exam_type,
    exam_date,
    maximum_score,
    weight_percentage
)
VALUES (
    (SELECT offering_id
     FROM course_offerings co
     JOIN courses c ON c.course_id = co.course_id
     WHERE c.course_code = 'MATH153'
       AND co.section_code = '01'),
    'Calculus Final',
    'FINAL',
    DATE '2026-01-07',
    100,
    100
);


-- =========================================================
-- 11. GRADES
-- =========================================================

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    78,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN courses c
    ON c.course_id = co.course_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Database Midterm'
  AND s.student_number = '20210001';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    88,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN courses c
    ON c.course_id = co.course_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Database Final'
  AND s.student_number = '20210001';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    92,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN courses c
    ON c.course_id = co.course_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Database Midterm'
  AND s.student_number = '20210002';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    85,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN courses c
    ON c.course_id = co.course_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Database Final'
  AND s.student_number = '20210002';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    74,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Data Structures Midterm'
  AND s.student_number = '20220003';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    81,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Data Structures Final'
  AND s.student_number = '20220003';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    69,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Data Structures Midterm'
  AND s.student_number = '20210001';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    76,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Data Structures Final'
  AND s.student_number = '20210001';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    84,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Circuit Theory Final'
  AND s.student_number = '20210004';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    71,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Circuit Theory Final'
  AND s.student_number = '20220005';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    90,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Calculus Final'
  AND s.student_number = '20210002';

INSERT INTO grades (exam_id, enrollment_id, score, graded_at)
SELECT
    ex.exam_id,
    en.enrollment_id,
    87,
    SYSDATE
FROM exams ex
JOIN course_offerings co
    ON co.offering_id = ex.offering_id
JOIN enrollments en
    ON en.offering_id = co.offering_id
JOIN students s
    ON s.student_id = en.student_id
WHERE ex.exam_name = 'Calculus Final'
  AND s.student_number = '20210006';


COMMIT;

PROMPT Sample data loaded successfully.

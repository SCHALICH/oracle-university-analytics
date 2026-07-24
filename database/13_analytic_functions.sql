PROMPT ==========================================
PROMPT ROW_NUMBER
PROMPT ==========================================

SELECT
    student_number,
    first_name,
    last_name,
    enrollment_year,
    ROW_NUMBER() OVER (
        ORDER BY enrollment_year, student_number
    ) AS row_num
FROM students;

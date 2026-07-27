# Veri Sözlüğü

| Tablo | Amaç | Temel alanlar |
|---|---|---|
| `UNIVERSITIES` | Üniversite ana kaydı | `university_code`, `university_name`, `city` |
| `FACULTIES` | Üniversiteye bağlı fakülteler | `faculty_code`, `faculty_name`, `university_id` |
| `DEPARTMENTS` | Fakülteye bağlı bölümler | `department_code`, `department_name`, `faculty_id` |
| `STUDENTS` | Öğrenci bilgileri | `student_number`, `department_id`, `enrollment_year`, `status` |
| `INSTRUCTORS` | Öğretim elemanları | `employee_number`, `department_id`, `academic_title` |
| `COURSES` | Ders kataloğu | `course_code`, `credits`, `course_level`, `department_id` |
| `SEMESTERS` | Akademik dönemler | `semester_code`, `start_date`, `end_date`, `status` |
| `COURSE_OFFERINGS` | Bir dersin dönemlik açılışı | `course_id`, `instructor_id`, `semester_id`, `section_code` |
| `ENROLLMENTS` | Öğrencinin ders açılışına kaydı | `student_id`, `offering_id`, `attendance_rate` |
| `EXAMS` | Ders açılışına ait sınavlar | `offering_id`, `exam_type`, `maximum_score`, `weight_percentage` |
| `GRADES` | Öğrenci sınav sonuçları | `exam_id`, `enrollment_id`, `score` |

## Ortak kurallar

- Kimlik alanları `NUMBER` tipindedir ve varsayılan olarak identity ile üretilir.
- `created_at` alanları oluşturulma zamanını `SYSDATE` ile kaydeder.
- E-posta alanları isteğe bağlıdır; mevcutsa öğrenci ve öğretim elemanı
  tablolarında benzersizdir.
- `attendance_rate` ve sınav ağırlıkları 0–100 aralığındadır.
- Dönem bitiş tarihi başlangıç tarihinden sonra olmalıdır.

# Veritabanı Tasarımı

## Varlık ilişkileri

```text
universities 1 ── N faculties
faculties    1 ── N departments
departments  1 ── N students
departments  1 ── N instructors
departments  1 ── N courses
courses      1 ── N course_offerings
instructors  1 ── N course_offerings
semesters    1 ── N course_offerings
students     N ── N course_offerings (enrollments üzerinden)
course_offerings 1 ── N exams
enrollments      1 ── N grades
exams            1 ── N grades
```

## Tasarım kararları

- İş anahtarları (`student_number`, `course_code` gibi) benzersiz tutulur.
- Sayısal kimlikler ilişkilerde kararlı ve kısa yabancı anahtarlar sağlar.
- Çoktan çoğa öğrenci–ders ilişkisi `enrollments` ile çözülür.
- Bir not hem sınava hem öğrenci kaydına bağlanır; benzersiz kısıt aynı
  sınav için mükerrer notu engeller.
- Durum alanları `CHECK` kısıtlarıyla kontrollü değer kümelerine bağlıdır.
- Yabancı anahtar sütunları rapor ve birleştirme performansı için
  `06_indexes.sql` içinde indekslenir.

## Kurulum sırası

1. Tablolar ve bütünlük kuralları
2. Örnek veri
3. Görünümler ve indeksler
4. Sequence, trigger, procedure ve package örnekleri
5. İleri SQL ve raporlama örnekleri

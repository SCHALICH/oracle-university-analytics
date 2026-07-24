# Oracle University Analytics

Oracle AI Database 26ai üzerinde geliştirilen üniversite bilgi yönetimi ve öğrenci analitiği projesi.

## Proje Amacı

Bu proje; öğrenciler, bölümler, dersler, öğretim üyeleri, dönemler, kayıtlar, sınavlar ve notlar arasındaki ilişkileri Oracle Database üzerinde modellemek için hazırlanmıştır.

Proje kapsamında:

- İlişkisel veritabanı tasarımı
- SQL sorguları
- PL/SQL geliştirme
- View, sequence ve index kullanımı
- Veri analizi
- Python ile Oracle bağlantısı
- Öğrenci başarı ve risk analizi
- Makine öğrenmesi uygulamaları

gerçekleştirilecektir.

## Kullanılan Teknolojiler

- Oracle AI Database 26ai Free
- SQL
- PL/SQL
- SQLcl
- DBeaver
- VS Code
- Python
- Pandas
- Scikit-learn
- Matplotlib
- Git ve GitHub

## Proje Yapısı

```text
oracle-university-analytics/
├── database/
├── plsql/
├── analytics/
├── python/
├── datasets/
├── docs/
├── README.md
├── LICENSE
└── .gitignore
'''bash
cat README.md
cat > docs/database-design.md <<'EOF'
# Database Design

## Amaç

Bu veritabanı, bir üniversitenin akademik yapısını ve öğrenci süreçlerini yönetmek için tasarlanmıştır.

## Ana Varlıklar

### FACULTIES
Üniversitedeki fakülteleri tutar.

### DEPARTMENTS
Fakültelere bağlı bölümleri tutar.

### STUDENTS
Öğrencilerin temel bilgilerini tutar.

### INSTRUCTORS
Öğretim üyelerinin bilgilerini tutar.

### COURSES
Derslerin tanımlarını ve kredi bilgilerini tutar.

### SEMESTERS
Akademik dönemleri tutar.

### COURSE_OFFERINGS
Bir dersin belirli bir dönemde hangi öğretim üyesi tarafından açıldığını tutar.

### ENROLLMENTS
Öğrencilerin açılan derslere kayıtlarını tutar.

### EXAMS
Derslere ait sınavları tutar.

### GRADES
Öğrencilerin sınav sonuçlarını tutar.

## Temel İlişkiler

- Bir fakültenin birden fazla bölümü olabilir.
- Bir bölümün birden fazla öğrencisi olabilir.
- Bir bölümün birden fazla öğretim üyesi olabilir.
- Bir bölümün birden fazla dersi olabilir.
- Bir ders farklı dönemlerde birden fazla kez açılabilir.
- Bir öğrenci birden fazla derse kayıt olabilir.
- Bir ders açılışında birden fazla öğrenci bulunabilir.
- Bir ders açılışının birden fazla sınavı olabilir.
- Bir öğrencinin her sınav için bir notu olabilir.

## İlişki Özeti

FACULTIES
  |
  └── DEPARTMENTS
        ├── STUDENTS
        ├── INSTRUCTORS
        └── COURSES

COURSES
  |
  └── COURSE_OFFERINGS
        ├── ENROLLMENTS
        └── EXAMS

STUDENTS
  |
  └── ENROLLMENTS
        └── GRADES

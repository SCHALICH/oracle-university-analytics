# Oracle University Analytics

Oracle AI Database 26ai üzerinde geliştirilen üniversite bilgi yönetimi,
akademik raporlama ve öğrenci başarı analitiği projesidir.

## Kapsam

- Üniversite, fakülte, bölüm, öğrenci ve öğretim üyesi yönetimi
- Ders, dönem, ders açılışı, kayıt, sınav ve not modeli
- Oracle SQL ve PL/SQL örnekleri
- Analitik fonksiyonlar, CTE, alt sorgular ve küme operatörleri
- `MERGE`, `PIVOT`/`UNPIVOT`, JSON, XML ve materialized view örnekleri
- Yönetici raporları
- Python ve Random Forest ile not tahmini
- SH Sample Schema ile satış tahmini ve zaman serisi analizi

## Teknolojiler

- Oracle AI Database 26ai Free
- SQL*Plus veya SQLcl
- PL/SQL
- Python 3.11+
- Pandas ve scikit-learn

## Proje yapısı

```text
oracle-university-analytics/
├── database/                              # DDL, örnek veri ve SQL raporları
├── docs/                                  # Tasarım dokümanları
├── oracle-university-python-analytics/    # Python modelleme çalışması
├── sh-sales-analytics/                    # SH satış/ML analitiği
├── analytics/                             # Analiz çıktıları için ayrılmış alan
├── datasets/                              # Dışa aktarılan veri kümeleri
├── plsql/                                 # Ek PL/SQL çalışmaları
├── README.md
└── LICENSE
```

Genel ilerleme planı ve doğrulama durumu için [ROADMAP.md](ROADMAP.md)
belgesine bakın.

## Veritabanı modeli

```text
UNIVERSITIES
    └── FACULTIES
        └── DEPARTMENTS
            ├── STUDENTS
            ├── INSTRUCTORS
            └── COURSES
                └── COURSE_OFFERINGS
                    ├── ENROLLMENTS
                    │   └── GRADES
                    └── EXAMS
```

## Kurulum ve çalıştırma

Yeni veya boş bir Oracle şemasında tek komutla kurulum:

```sql
@database/00_install.sql
```

`database/11_cursors.sql` ile `database/25_final_reporting.sql` arasındaki
dosyalar bağımsız öğrenme ve raporlama örnekleridir. Bazıları yardımcı nesne
oluşturduğu için dosya numarası sırasıyla çalıştırılması önerilir.

Python modelini çalıştırmadan önce
`oracle-university-python-analytics/README.md` içindeki ortam değişkenlerini
ayarlayın.

## Notlar

- `01_create_tables_backup.sql`, ilk şema taslağını tarihsel referans olarak
  korur ve kurulum sırasında çalıştırılmaz.
- Model dosyaları yeniden üretilebilir çıktılardır; kaynak kodun yerine
  geçmezler.

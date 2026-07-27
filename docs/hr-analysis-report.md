# HR Şeması Analiz Raporu

## Amaç

HR şeması, organizasyon yapısını çalışan, departman, görev ve coğrafi konum
boyutlarıyla incelemek için kullanılır.

## Temel tablolar

| Tablo | Rol |
|---|---|
| `EMPLOYEES` | Çalışan, yönetici, görev, maaş ve departman bilgisi |
| `DEPARTMENTS` | Departman ve departman yöneticisi |
| `JOBS` | Görev adı ile minimum/maksimum maaş aralığı |
| `JOB_HISTORY` | Çalışanın geçmiş görev ve departman hareketleri |
| `LOCATIONS` | Adres, şehir ve ülke bilgisi |
| `COUNTRIES` | Ülke ve bölge ilişkisi |
| `REGIONS` | En üst coğrafi sınıflandırma |

## İlişkiler

```text
REGIONS 1 ── N COUNTRIES
COUNTRIES 1 ── N LOCATIONS
LOCATIONS 1 ── N DEPARTMENTS
DEPARTMENTS 1 ── N EMPLOYEES
JOBS 1 ── N EMPLOYEES
EMPLOYEES 1 ── N EMPLOYEES (manager ilişkisi)
EMPLOYEES 1 ── N JOB_HISTORY
```

## Analiz başlıkları

- Departman bazında çalışan sayısı ve toplam maaş maliyeti
- Görev bazında ortalama, minimum ve maksimum maaş
- Yönetici başına bağlı çalışan sayısı
- Ülke ve bölge bazında organizasyon dağılımı
- İş geçmişi bulunan çalışanlar ve görev değişimleri
- Tanımlı görev maaş aralığı dışındaki çalışan maaşları
- Çalışanı olmayan departmanlar

## Örnek yönetim sorgusu

```sql
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    SUM(e.salary) AS monthly_salary_total
FROM hr.departments d
LEFT JOIN hr.employees e
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY monthly_salary_total DESC NULLS LAST;
```

## Veri kalitesi kontrolleri

- `EMPLOYEES.DEPARTMENT_ID` değeri bulunmayan çalışanlar
- Yöneticisi kendisi olan veya geçersiz yöneticiye bağlı çalışanlar
- Görev maaş sınırlarını aşan çalışan maaşları
- Başlangıç tarihi bitiş tarihinden sonra olan iş geçmişi kayıtları
- Departmanı olmayan lokasyonlar ve lokasyonu olmayan ülkeler

## Sonuç

HR şeması normalizasyon, birincil/yabancı anahtar ilişkileri, self join,
hiyerarşik sorgu, toplulaştırma ve analitik raporlama çalışmalarını tek ve
anlaşılır bir model üzerinde göstermektedir.

# Gerçek Model Sonuçları

Bu sonuçlar satış verisinden değil, üniversite veritabanındaki öğrenci notlarından
üretilmiştir. Random Forest tekil not skorunu, SARIMAX aylık ortalama notu modeller.

## Random Forest

- Toplam kayıt: **2,976**
- Eğitim / test: **2,380 / 596**
- MAE: **6.61**
- RMSE: **8.31**
- R²: **0.134**

R² değeri modelin tek başına güçlü bir nihai tahminleyici olmadığını gösterir.
Bu sonuç, daha zengin öğrenci geçmişi ve ders bağlamı değişkenleri için başlangıç
ölçütü olarak kullanılmalıdır.

### En önemli değişkenler

- `numeric__ATTENDANCE_RATE`: 0.6708
- `numeric__ENROLLMENT_YEAR`: 0.1016
- `numeric__COURSE_LEVEL`: 0.0437
- `numeric__DEPARTMENT_ID`: 0.0364
- `numeric__WEIGHT_PERCENTAGE`: 0.0295
- `categorical__STUDENT_STATUS_ACTIVE`: 0.0187
- `categorical__EXAM_TYPE_MIDTERM`: 0.0183
- `categorical__STUDENT_STATUS_INACTIVE`: 0.0169
- `categorical__STUDENT_STATUS_GRADUATED`: 0.0169
- `categorical__ENROLLMENT_STATUS_COMPLETED`: 0.0159

## SARIMAX

- Toplam dönem: **25 ay**
- Test dönemi: **6 ay**
- MAE: **1.43**
- RMSE: **1.79**
- MAPE: **%2.10**
- Model: **SARIMAX(1, 1, 1) × (1, 0, 1, 12)**

| Ay | Tahmin | Güven aralığı |
|---|---:|---:|
| 2026-08 | 70.11 | 68.02–72.20 |
| 2026-09 | 68.82 | 66.22–71.41 |
| 2026-10 | 68.87 | 65.87–71.88 |
| 2026-11 | 70.46 | 67.10–73.83 |
| 2026-12 | 70.15 | 66.46–73.83 |
| 2027-01 | 67.39 | 63.41–71.37 |

SARIMAX kısa vadeli aylık ortalama not tahmininde Random Forest'tan farklı bir
soruyu yanıtlar. Bu nedenle iki modelin metrikleri doğrudan “kazanan model”
seçmek için değil, kullanım amacına göre değerlendirilmelidir.

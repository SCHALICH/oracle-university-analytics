# SH Sales Analytics

Oracle Sample Schemas içindeki SH satış verilerini makine öğrenmesi ve zaman
serisi modelleri için hazırlayan bağımsız modüldür.

Bu modül, üniversite şemasıyla aynı depoda yer alır ancak farklı bir Oracle
kullanıcısı ve veri modeli kullanır.

## Planlanan akış

1. `sql/01_monthly_sales_dataset.sql` ile aylık kategori satışlarını üret.
2. Sonucu `datasets/sh_monthly_sales.csv` olarak dışa aktar.
3. Veri kalite kontrollerini çalıştır.
4. Random Forest ve SARIMAX modellerini aynı veri kesitiyle eğit.
5. Sonuçları ortak metriklerle karşılaştır.

## Beklenen CSV alanları

| Alan | Açıklama |
|---|---|
| `MONTH_START` | Ayın ilk günü |
| `CALENDAR_YEAR` | Takvim yılı |
| `CALENDAR_MONTH_NUMBER` | Ay numarası |
| `PRODUCT_CATEGORY` | Ürün kategorisi |
| `CHANNEL_DESC` | Satış kanalı |
| `TOTAL_QUANTITY` | Toplam satış adedi |
| `TOTAL_AMOUNT` | Toplam satış tutarı |
| `AVERAGE_UNIT_PRICE` | Ortalama birim fiyat |
| `CUSTOMER_COUNT` | Benzersiz müşteri sayısı |
| `TRANSACTION_COUNT` | Satış satırı sayısı |

## CSV dışa aktarımı

SQLcl içinde:

```sql
@sql/01_monthly_sales_dataset.sql
```

Dosya, SQLcl'nin çalıştırıldığı dizindeki `datasets` klasörüne yazılır.

## Python kurulumu

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

## Modeller

Komutları `sh-sales-analytics` klasöründe çalıştırın:

```powershell
python -m models.random_forest
python -m models.sarimax
python -m models.compare_models
```

Üretilen model, tahmin, metrik, grafik ve karşılaştırma dosyaları `outputs/`
klasörüne yazılır. Test bölümü son üç ayı kronolojik olarak ayırır; böylece
gelecek verisinin eğitim verisine sızması önlenir.

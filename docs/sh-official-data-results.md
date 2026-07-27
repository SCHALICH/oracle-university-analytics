# SH Satış Analitiği — Resmî Örnek Veri Sonuçları

Bu çalışma, Oracle'ın `oracle-samples/db-sample-schemas` deposundaki resmî
`sales_history/sales.csv` dosyasından üretilmiştir. Sanal makinedeki listener
27 Temmuz 2026 tarihinde dış bağlantıya yanıt vermediği için, aynı SH örnek
şemasının resmî kaynak verisi tekrar üretilebilir bir yedek yol olarak kullanıldı.

Kaynak: <https://github.com/oracle-samples/db-sample-schemas/tree/main/sales_history>

## Veri hazırlama

- Satışlar ay, ürün ve kanal kimliği seviyesinde toplandı.
- Toplam miktar ve satış tutarı hesaplandı.
- Müşteri ve işlem sayıları üretildi.
- Ortalama birim fiyat `TOTAL_AMOUNT / TOTAL_QUANTITY` olarak hesaplandı.
- Ürün ve kanal açıklama tabloları olmadan da tekrar üretilebilir olması için
  kategorik etiketler `PRODUCT_<id>` ve `CHANNEL_<id>` biçiminde oluşturuldu.

## Çalıştırma

```bash
python datasets/build_from_oracle_official.py /path/to/sales.csv
python -m models.random_forest
python -m models.sarimax
python -m models.compare_models
```

Gerçek metrikler ve tahminler `sh-sales-analytics/outputs` klasöründedir.

## Doğrulanan sonuçlar

| Model | Hedef seviyesi | MAE | RMSE | MAPE |
|---|---|---:|---:|---:|
| Random Forest | Ay × ürün × kanal | 289,28 | 1.324,68 | %1,50 |
| SARIMAX | Aylık toplam satış | 83.565,60 | 90.688,93 | %3,33 |

Modeller farklı büyüklükte hedefleri tahmin ettiği için mutlak hata değerleri
birbirine karşı “kazanan model” seçmek amacıyla kullanılmamalıdır.

Random Forest'ta en önemli değişkenler:

1. Ortalama birim fiyat: %57,20
2. Toplam miktar: %16,54
3. İşlem sayısı: %16,34
4. Müşteri sayısı: %8,43

SARIMAX'ın üç aylık toplam satış tahmini:

| Ay | Tahmin | %95 güven aralığı |
|---|---:|---:|
| 2023-01 | 2.576.339 | 2.176.782–2.975.896 |
| 2023-02 | 2.565.639 | 2.134.612–2.996.667 |
| 2023-03 | 2.750.592 | 2.306.953–3.194.231 |

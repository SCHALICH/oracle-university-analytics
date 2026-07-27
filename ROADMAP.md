# Oracle Analytics Yol Haritası

Bu belge, bildirilen çalışmaları depoda doğrulanabilen çıktılardan ayırır.

## Tamamlanan ve depoda doğrulanan çalışmalar

- Oracle 19c ve Oracle AI Database 26ai çalışma ortamı
- HR, SH, OE, PM ve CO sample schema kurulumları
- HR şeması analizi ve veri sözlüğü
- 19c–26ai karşılaştırma raporu
- Üniversite veritabanı tablo, kısıt ve indeks betikleri
- Python bağlantı yapılandırması
- Üniversite notları için Random Forest modeli
- Aylık ortalama not için SARIMAX modeli ve altı aylık tahmin
- Gerçek model metrikleri, tahmin CSV'si ve model dosyaları
- Model sonuç raporu, feature importance ve tahmin grafikleri
- SH satış analitiği için SQL, Random Forest, SARIMAX ve karşılaştırma kodu
- Proje sunumu ve paketlenmiş teslim

## Doğrulanan gerçek model sonuçları

| Model | Veri | Test sonucu |
|---|---|---|
| Random Forest | 2.976 not kaydı | RMSE 8,31; R² 0,134 |
| SARIMAX | 25 aylık ortalama not | RMSE 1,79; MAPE %2,10 |

Bu iki model farklı hedefleri tahmin eder. Random Forest tekil not skorunu,
SARIMAX aylık ortalama notu tahmin eder; metrikleri doğrudan aynı yarışın sonucu
gibi yorumlanmamalıdır.

## SH resmî örnek veri çalışması

Oracle'ın resmî `db-sample-schemas` deposundaki SH satış CSV'si için veri
hazırlama ve model hattı depoya eklenmiştir. Sonuçlar
`docs/sh-official-data-results.md` belgesinde ve
`sh-sales-analytics/outputs` klasöründedir.

## Kalan geliştirme işleri

1. Sanal makinedeki listener yeniden erişilebilir olduğunda yerel SH CSV'sini
   dışa aktarıp resmî kaynak sonuçlarıyla karşılaştırmak.
2. DBeaver/SQLcl ekran görüntülerini raporlara yerleştirmek.
3. Son değişiklikleri sanal makinedeki Git çalışma kopyasına aktarmak ve commit etmek.

Kritik yolun ilk adımı gerçek SH CSV dışa aktarımıdır. Depodaki
`sh-sales-analytics/sql/01_monthly_sales_dataset.sql` ve
`02_data_quality_checks.sql` bu işlem için hazırdır.

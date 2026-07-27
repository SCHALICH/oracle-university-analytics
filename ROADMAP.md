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

Oracle AI Database 26ai `FREEPDB1` içine resmî SH şeması ayrıca kurulmuş,
918.843 satış satırı ve tüm temel nesneler doğrulanmıştır. Canlı veritabanı
dışa aktarımıyla modeller yeniden çalıştırılmıştır. Ayrıntılı kayıt:
`docs/sh-freepdb1-installation-report.md`.

## Kalan geliştirme işleri

1. DBeaver/SQLcl ekran görüntülerini raporlara yerleştirmek.
2. Kullanıcı onayından sonra iki kayıt dışı VM adayından hangisinin Oracle 19c
   içerdiğini başlatıp salt-okunur SQL kontrolleriyle kesinleştirmek.

Oracle 19c adaylarına ilişkin mevcut güvenli bulgular
`docs/oracle-19c-inventory.md` belgesindedir. FREEPDB1 üzerindeki resmî SH
kurulumu, gerçek CSV dışa aktarımı ve model doğrulaması tamamlanmıştır.

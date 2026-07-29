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

## Son durum

- FREEPDB1 ve SH için canlı SQL*Plus doğrulama kanıtı alındı.
- Eski VM'ler kullanıcı açıklamasıyla envanterlendi; proje için yetkili çalışma
  ortamının ana `oracle` VM içindeki `cem` hesabı olduğu kesinleşti.
- FREEPDB1 açılış durumu `SAVE STATE` ile kaydedildi.
- Resmî SH kurulumu, gerçek CSV dışa aktarımı, modeller, rapor, sunum ve teslim
  paketi tamamlandı.

Yeni bir kapsam eklenmedikçe yol haritasındaki zorunlu iş kalmamıştır.

## Kurumsal platform aşaması

İkinci çalışma fazı başlatılmıştır:

- Ayrı `DevOps-Lab` Oracle Linux 9 VM kuruldu.
- Rootless Podman çalışma ortamı kuruldu ve doğrulandı.
- FastAPI tabanlı ilk REST API geliştirildi.
- API container imajı oluşturuldu ve sağlık kontrolüyle çalıştırıldı.
- Windows üzerinden `http://127.0.0.1:8000` erişimi doğrulandı.
- Container için yeniden başlatma politikası etkinleştirildi.
- Nginx ters proxy container'ı kuruldu ve sağlık kontrolü doğrulandı.
- Nginx ile FastAPI özel Podman ağı üzerinden birbirine bağlandı.
- Doğrudan API erişimi kapatıldı; dış erişim Nginx `8080` portuna taşındı.
- Redis 7.4 önbellek servisi özel Podman ağına eklendi.
- Redis verileri kalıcı `redis-data` volume üzerinde saklandı ve dışarıya port açılmadı.
- FastAPI sağlık kontrolü Redis durumunu gösterecek şekilde genişletildi.
- Proje uç noktasında ilk isteğin `miss`, sonraki isteğin `hit` verdiği doğrulandı.
- GitHub Actions CI hattı eklendi.
- API birim testleri, Python derleme kontrolü ve API/Nginx container imajı
  derlemeleri her gönderim ve pull request için otomatikleştirildi.
- SonarQube Community Build ve PostgreSQL kalıcı volume'larla DevOps-Lab
  ortamına kuruldu.
- SonarQube için zorunlu Linux çekirdek ayarları kalıcılaştırıldı.
- Proje SonarQube'a kaydedildi ve resmî SonarScanner container'ıyla analiz edildi.
- İlk kalite kapısı `OK`; 0 bug, 0 vulnerability ve 4 code smell sonucu alındı.
- DevOps-Lab üzerine SELinux destekli tek düğümlü K3s kümesi kuruldu.
- Kubernetes düğümü, CoreDNS ve local-path kalıcı depolama doğrulandı.
- Redis, FastAPI ve Nginx Kubernetes üzerinde ayrı Deployment/Service
  kaynaklarıyla çalıştırıldı.
- Redis için 1 GiB kalıcı disk, pod sağlık kontrolleri, kaynak sınırları ve
  yetkisiz kullanıcı güvenlik ayarları eklendi.
- Kubernetes sürümüne Windows `127.0.0.1:8081` üzerinden erişim doğrulandı.
- Kubernetes üzerinde Redis önbelleğinin `miss` ve `hit` davranışı doğrulandı.
- CI başarılı olduğunda API ve Nginx imajlarını GitHub Container Registry'ye
  `latest` ve commit SHA etiketleriyle yayımlayan hat eklendi.

Sonraki adımlar: otomatik Kubernetes dağıtımı ve test kapsamını analitik
modüllere genişletme.

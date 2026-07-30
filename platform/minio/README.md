# MinIO

MinIO, DevOps-Lab üzerinde eğitim ve geliştirme amaçlı tek düğümlü S3 uyumlu
nesne depolama servisi olarak çalışır.

## Yapı

- Sabitlenmiş `minio/minio:RELEASE.2025-09-07T16-13-09Z` imajı
- Kalıcı `minio-data` volume
- 512 MiB container bellek sınırı
- S3 API: VM `9100` → container `9000`
- Yönetim konsolu: VM `9101` → container `9001`
- Root bilgileri yalnızca VM içindeki izinleri kısıtlı dosyada tutulur

## Windows erişimi

- Konsol: `http://127.0.0.1:9101`
- S3 API: `http://127.0.0.1:9100`

## Kullanım

`university-reports` bucket'ı uygulama tarafından üretilecek analiz, tahmin ve
rapor dosyaları için ayrılmıştır.

FastAPI içindeki `POST /api/v1/reports` endpoint'i metin ve Markdown
raporlarını bu bucket'a kaydeder. Kubernetes Deployment, bağlantı adresini ve
erişim bilgilerini `minio-connection` Secret nesnesinden alır. Parola manifest
veya GitHub deposunda tutulmaz.

MinIO'nun bu tek düğümlü kurulumu eğitim/geliştirme içindir. Üretim ortamında
çoklu disk, erasure coding, TLS, yedekleme ve ayrı kullanıcı politikaları
gereklidir.

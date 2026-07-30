# Felaket Kurtarma (DR) Laboratuvarı

Bu çalışma, University Platform için tekrar üretilebilir bir yedekleme ve
doğrulama akışı sağlar. Mevcut servisleri durdurmaz ve kaynak verileri
değiştirmez.

## Yedeklenenler

- `university-platform` namespace tanımı
- Deployment, Service, ConfigMap ve PVC tanımları
- `university-logs-*` Elasticsearch belgeleri
- Dosya bütünlüğü için SHA-256 özetleri
- Oluşturulma zamanı ve ortam bilgisi

Kubernetes Secret nesneleri bilinçli olarak yedeğe eklenmez. Üretimde sırlar
Vault snapshot ve şifreli, erişimi kısıtlı ayrı bir yedekleme politikasıyla
korunmalıdır.

## Yedek oluşturma

```bash
chmod +x backup.sh verify_backup.sh
./backup.sh
```

Arşiv varsayılan olarak `~/university-backups` altında oluşturulur ve yalnızca
dosya sahibinin okuyabileceği `600` izniyle saklanır.

## Doğrulama

```bash
./verify_backup.sh ~/university-backups/university-dr-YYYYMMDDTHHMMSSZ.tar.gz
```

Doğrulama; arşivin açılabildiğini, zorunlu dosyaları ve tüm SHA-256 özetlerini
kontrol eder. Canlı sisteme veri yazmaz.

## Geri yükleme sırası

1. Temiz Kubernetes hedefinde namespace tanımını uygula.
2. Deployment, Service, ConfigMap ve PVC tanımlarını uygula.
3. Vault üzerinden gerekli sırları güvenli şekilde yeniden oluştur.
4. Elasticsearch indeks şablonunu oluştur.
5. NDJSON loglarını Elasticsearch Bulk API ile içeri aktar.
6. Pod ve servis sağlık kontrollerini çalıştır.
7. Uygulama, kimlik doğrulama ve log arama kabul testlerini tamamla.

Gerçek geri yükleme canlı durumu değiştireceğinden otomatik çalıştırılmaz ve
öncesinde açık onay gerektirir.

## Hedefler

- RPO: Eğitim ortamında en fazla 24 saatlik veri kaybı
- RTO: Belgelenmiş adımlarla 2 saat içinde temel platformu ayağa kaldırma
- Yedek doğrulama: Her yedekten sonra
- Geri yükleme tatbikatı: Aylık, izole namespace veya ayrı VM üzerinde

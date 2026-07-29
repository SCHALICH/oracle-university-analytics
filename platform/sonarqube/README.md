# SonarQube Kod Kalitesi

DevOps-Lab üzerinde SonarQube Community Build ve PostgreSQL ayrı container'larda
çalışır. PostgreSQL dış ağa açılmaz; SonarQube yalnızca Windows
`127.0.0.1:9000` adresine yönlendirilir.

## Kalıcı bileşenler

- `sonarqube-net`: SonarQube ile PostgreSQL arasındaki özel ağ
- `sonarqube-db`: PostgreSQL verileri
- `sonarqube-data`: SonarQube verileri ve arama indeksleri
- `sonarqube-logs`: servis günlükleri
- `sonarqube-extensions`: eklentiler
- `sonar-scanner-cache`: analiz eklentisi önbelleği

Veritabanı parolası ve analiz token'ı kaynak depoya yazılmaz.

## Doğrulama

```bash
curl http://127.0.0.1:9000/api/system/status
```

Beklenen servis durumu:

```json
{"status":"UP"}
```

Analiz ayarları depo kökündeki `sonar-project.properties` dosyasındadır.
SonarScanner resmî container imajıyla ve `SONAR_TOKEN` ortam değişkeniyle
çalıştırılır.

## İlk doğrulanan analiz

- Quality Gate: `OK`
- Bugs: `0`
- Vulnerabilities: `0`
- Code Smells: `4`
- Duplicated Lines: `%0,0`
- Analiz edilen kod: `1.258` satır
- Genel Python coverage: `%6,2`

API birim testlerinin kendi kapsamı `%97` seviyesindedir. Genel oranın daha düşük
olmasının nedeni diğer analitik Python modülleri için henüz birim test
bulunmamasıdır.

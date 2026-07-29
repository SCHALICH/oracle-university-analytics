# Jenkins

Jenkins, DevOps-Lab üzerinde rootless Podman container'ı olarak çalışır.
SonarQube ile aynı anda yüksek bellek tüketmemesi için Jenkins etkinleştirilirken
SonarQube geçici olarak durdurulur.

## Özellikler

- Jenkins LTS ve Java 21
- Kalıcı `jenkins-home` volume
- 768 MiB container bellek sınırı ve 512 MiB Java heap
- Git, GitHub, Pipeline ve JUnit eklentileri
- Python 3 sanal ortamıyla FastAPI testleri
- GitHub'daki `main` dalından otomatik oluşturulan Pipeline işi
- Yönetici bilgisinin yalnızca VM içinde tutulması

## Erişim

VirtualBox NAT yönlendirmesi üzerinden:

`http://127.0.0.1:8082`

## Pipeline

Kök dizindeki `Jenkinsfile` şu adımları çalıştırır:

1. GitHub deposunu indirir.
2. Python sanal ortamını oluşturur.
3. API bağımlılıklarını kurar.
4. Python kaynaklarını derleme kontrolünden geçirir.
5. Pytest, coverage ve JUnit raporlarını üretir.
6. Test ve coverage çıktılarını Jenkins'te saklar.

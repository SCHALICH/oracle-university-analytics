# GitLab CI/CD

Kök dizindeki `.gitlab-ci.yml`, proje GitLab'a aktarıldığında veya
aynalandığında otomatik olarak kullanılır.

## Pipeline

Pipeline iki aşamadan oluşur:

1. `api-tests`
   - Python 3.12 ortamını hazırlar.
   - API kaynaklarını derleme kontrolünden geçirir.
   - Pytest testlerini çalıştırır.
   - JUnit ve Cobertura coverage raporlarını GitLab'a yükler.
2. `build-api-image` ve `build-nginx-image`
   - Testler başarılı olduktan sonra paralel çalışır.
   - API ve Nginx container imajlarını oluşturur.
   - İmajları commit SHA etiketiyle GitLab Container Registry'ye gönderir.
   - Varsayılan dalda ayrıca `latest` etiketi oluşturur.

## Runner gereksinimi

Container işleri `docker:dind` kullanır. Self-managed GitLab Runner
kullanılırsa Docker veya Kubernetes executor ve privileged çalışma desteği
gerekir. GitLab.com üzerinde uygun bir runner seçilmelidir.

GitLab sunucusunun kendisi DevOps-Lab VM'ye kurulmamıştır. GitLab CE,
SonarQube, Jenkins ve K3s ile aynı anda bu VM'nin güvenli bellek kapasitesini
aşar. Pipeline dosyası GitLab.com veya ayrı bir GitLab sunucusunda çalışacak
şekilde hazırlanmıştır.

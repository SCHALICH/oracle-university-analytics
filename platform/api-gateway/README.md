# Kong API Gateway

Kong Gateway, üniversite platformunun merkezi API giriş noktasıdır.

## Laboratuvar kurulumu

- İmaj: `docker.io/library/kong:3.9.3`
- Çalışma modu: DB-less
- Proxy adresi: `http://127.0.0.1:8083`
- VM içi Admin API: `http://127.0.0.1:8001`
- Upstream: K3s üzerindeki Nginx ve üniversite API

## Etkin politikalar

- Her isteğe `X-Request-ID` eklenmesi
- IP başına dakikada 120 istek sınırı
- İstek gövdesinin 2 MiB ile sınırlandırılması
- Temel güvenlik yanıt başlıkları
- Prometheus metriklerinin üretilmesi

Kimlik ve rol doğrulaması üniversite API içinde Keycloak imzalı tokenlarla
yapılır. Gateway ortak trafik politikalarını, API ise iş yetkilerini uygular.

## Kontroller

```bash
curl http://127.0.0.1:8083/health
curl -I http://127.0.0.1:8083/api/v1/project
curl http://127.0.0.1:8001/status
curl http://127.0.0.1:8001/metrics
```

Bu DB-less ve HTTP tabanlı kurulum eğitim/geliştirme ortamı içindir.
Üretimde TLS, birden fazla gateway düğümü, merkezi kontrol düzlemi ve
dağıtık hız sınırlama deposu gerekir.

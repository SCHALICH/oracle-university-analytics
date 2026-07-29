# Nginx Gateway

Nginx, dış istemciler ile FastAPI servisi arasında ters proxy olarak çalışır.

- Nginx sağlık kontrolü: `/nginx-health`
- API sağlık kontrolü: `/health`
- API dokümantasyonu: `/docs`
- API uç noktaları: `/api/v1/*`

Nginx ve API aynı Podman ağı içinde servis adlarıyla haberleşir. FastAPI
container portunun doğrudan dışarı açılması üretim benzeri akışta gerekli
değildir.

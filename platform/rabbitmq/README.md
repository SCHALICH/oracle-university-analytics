# RabbitMQ

RabbitMQ, DevOps-Lab üzerinde rootless Podman container'ı olarak çalışır.

## Yapı

- Resmî `rabbitmq:4.3.4-management-alpine` imajı
- Kalıcı `rabbitmq-data` volume
- 384 MiB container bellek sınırı
- AMQP: `5672`
- Yönetim arayüzü: `15672`
- Yönetici bilgileri yalnızca VM içindeki izinleri kısıtlı dosyada tutulur

## Windows erişimi

- Yönetim arayüzü: `http://127.0.0.1:15672`
- AMQP bağlantısı: `amqp://127.0.0.1:5672`

## Doğrulama

```bash
podman exec rabbitmq rabbitmq-diagnostics -q ping
podman exec rabbitmq rabbitmqctl list_queues name messages consumers
```

Kurulum doğrulamasında yönetim API'si üzerinden geçici bir kuyruk oluşturulur,
mesaj yayınlanır, mesaj geri okunur ve geçici kuyruk silinir.

## API entegrasyonu

FastAPI içindeki `POST /api/v1/tasks` endpoint'i aşağıdaki görev türlerini
kalıcı `university.tasks` kuyruğuna gönderir:

- `grade-report`
- `sales-forecast`
- `student-risk-analysis`

Kubernetes Deployment, bağlantı adresini `rabbitmq-connection` Secret
nesnesindeki `url` anahtarından alır. Parola manifest veya GitHub deposunda
tutulmaz.

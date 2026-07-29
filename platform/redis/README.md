# Redis Cache

Redis, FastAPI servisinin sık kullanılan proje yanıtını kısa süreli bellekte
tutmak için kullanılır.

```bash
podman run -d \
  --name redis \
  --network university-platform \
  --restart=unless-stopped \
  --volume redis-data:/data \
  docker.io/library/redis:7.4-alpine \
  redis-server --appendonly yes
```

Redis yalnızca özel Podman ağına açılır; Windows veya dış ağ için port
yayımlanmaz. API bağlantıyı `REDIS_URL=redis://redis:6379/0` ortam
değişkeninden alır.

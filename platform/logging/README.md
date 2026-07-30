# Elasticsearch ve Kibana merkezi loglama

Bu laboratuvar, Kubernetes içindeki University API ve Nginx loglarıyla Kong API
Gateway loglarını Elasticsearch'e aktarır. Kibana üzerinden servis, zaman ve
mesaj alanlarına göre arama yapılabilir.

## Bileşenler

- Elasticsearch: Logları indeksler ve aranabilir hâle getirir.
- Kibana: `university-logs-*` veri görünümünü kullanarak logları gösterir.
- `ship_logs.py`: Son servis loglarını her dakika toplar.
- systemd kullanıcı zamanlayıcısı: Log taşıma işlemini otomatik çalıştırır.

## Erişim

- Elasticsearch: `http://127.0.0.1:9200`
- Kibana: `http://127.0.0.1:5601`
- Kibana menüsü: **Discover** → **University Logs**

## Kullanılan sürüm ve kaynak sınırları

- Elasticsearch `9.4.2`: 512 MB Java heap, 1 GB konteyner bellek sınırı
- Kibana `9.4.2`: 640 MB JavaScript heap, 1 GB konteyner bellek sınırı
- Elasticsearch verisi: `elasticsearch-data` Podman volume
- Ağ: `elastic-observability`

Elastic bileşenlerinin sürümleri aynı tutulmalıdır.

## Yeniden oluşturma

```bash
podman network create elastic-observability
podman volume create elasticsearch-data

podman run -d --name elasticsearch --replace \
  --network elastic-observability \
  -p 9200:9200 \
  --memory 1g --memory-swap 1280m \
  -e discovery.type=single-node \
  -e xpack.security.enabled=false \
  -e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
  -v elasticsearch-data:/usr/share/elasticsearch/data:Z \
  docker.io/library/elasticsearch:9.4.2

podman run -d --name kibana --replace \
  --network elastic-observability \
  -p 5601:5601 \
  --memory 1g --memory-swap 1280m \
  -e NODE_OPTIONS=--max-old-space-size=640 \
  -e ELASTICSEARCH_HOSTS=http://elasticsearch:9200 \
  docker.io/library/kibana:9.4.2
```

Log taşıyıcı:

```bash
mkdir -p ~/.config/systemd/user ~/university-platform/logging
cp ship_logs.py ~/university-platform/logging/
cp university-log-shipper.* ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now university-log-shipper.timer
```

## Doğrulama

```bash
curl -s http://127.0.0.1:9200/_cluster/health
curl -s http://127.0.0.1:9200/university-logs-*/_count
systemctl --user status university-log-shipper.timer
```

## Güvenlik notu

Bu yapı yalnızca yerel eğitim VM'i içindir. Elasticsearch güvenliği laboratuvarı
kolaylaştırmak amacıyla kapalıdır ve portlar VirtualBox üzerinden sadece yerel
bilgisayara yönlendirilmiştir. Üretimde TLS, kimlik doğrulama ve ağ erişim
kısıtlamaları etkinleştirilmelidir.

Kibana ilk açılışında 320 MB varsayılan JavaScript heap ile bellek hatası
verdiği için `NODE_OPTIONS` sınırı 640 MB olarak ayarlanmıştır. VM belleğini
korumak amacıyla kullanılmayan `sonarqube-db` konteyneri durdurulmuştur; verisi
silinmemiştir.

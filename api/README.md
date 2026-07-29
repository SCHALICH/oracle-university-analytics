# REST API

Bu modül, Oracle University Analytics projesinin platform çalışmalarında
kullanılacak ilk HTTP servisidir.

## Yerel container

```bash
podman build -t oracle-university-api:1.0 .
podman run --rm -p 8000:8000 oracle-university-api:1.0
```

## Uç noktalar

- `GET /health`
- `GET /api/v1/project`
- `GET /api/v1/platform`
- `GET /docs`

İlk sürüm veritabanından bağımsız bir sağlık ve proje tanıtım katmanıdır.
Oracle bağlantısı sonraki aşamada ortam değişkenleri ve Vault entegrasyonuyla
eklenecektir.

`GET /api/v1/project` yanıtı Redis içinde beş dakika tutulur. Yanıttaki
`cache` alanı ilk istekte `miss`, sonraki istekte `hit` değerini gösterir.

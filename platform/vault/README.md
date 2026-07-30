# HashiCorp Vault

Vault, DevOps-Lab üzerinde rootless Podman container'ı olarak ve kalıcı Raft
depolama ile çalışır.

## Erişim

- Arayüz ve API: `http://127.0.0.1:8200`
- Container imajı: `docker.io/hashicorp/vault:2.0.3`
- Container adı: `vault`
- Kalıcı volume: `vault-data`
- Secrets engine: `university/` (KV v2)

## Güvenlik dosyaları

İlk kurulumda oluşturulan unseal anahtarı ve root token yalnızca sanal makinede
şu dosyada saklanır:

```text
/home/vboxuser/.config/vault/init.json
```

Dosya izni `600` olmalıdır. Bu dosya GitHub deposuna eklenmez, kopyalanmaz ve
uygulama günlüklerinde gösterilmez.

## Durum kontrolü

```bash
curl http://127.0.0.1:8200/v1/sys/health
podman ps --filter name=vault
```

Vault yeniden başlatıldığında güvenlik gereği sealed durumda açılır. Unseal
işlemi VM'deki korumalı `init.json` dosyasındaki anahtarla, anahtar terminal
geçmişine yazılmadan yapılmalıdır.

## Ortam kapsamı

Bu tek düğümlü ve TLS'siz kurulum yalnızca yerel eğitim/geliştirme ortamı
içindir. Üretimde TLS, en az üç Raft düğümü, ayrı saklanan unseal anahtarları,
root token yerine sınırlı politikalar ve düzenli snapshot yedekleri gerekir.

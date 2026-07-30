# Keycloak

Keycloak, DevOps-Lab üzerinde öğrenci, öğretmen ve yönetici kimliklerini
yönetmek için kullanılır.

## Laboratuvar kurulumu

- İmaj: `quay.io/keycloak/keycloak:26.6.4`
- Container: `keycloak`
- Yerel adres: `http://127.0.0.1:8180`
- Realm: `university`
- OIDC client: `university-api`
- Roller: `student`, `instructor`, `university-admin`
- Kalıcı volume: `keycloak-data`

Realm tanımı `university-realm.json` dosyasındadır ve ilk açılışta içe
aktarılır. Yönetici ve örnek kullanıcı parolaları kaynak kodda tutulmaz.
Yalnızca VM içinde, kullanıcıya özel ve `600` izinli dosyalarda saklanır.

## OpenID Connect keşif adresi

```text
http://127.0.0.1:8180/realms/university/.well-known/openid-configuration
```

## Kapsam

Bu kurulum `start-dev` ile çalışan yerel eğitim ortamıdır. Üretimde TLS,
harici PostgreSQL, yüksek erişilebilirlik, güvenli hostname ayarları ve
doğrudan parola grant'i yerine Authorization Code + PKCE kullanılmalıdır.

# Oracle 19c Salt-Okunur Envanteri

Kontrol tarihi: 27 Temmuz 2026

## Doğrulanan mevcut durum

- VirtualBox içinde kayıtlı ve çalışan tek sanal makinenin adı `oracle`.
- Çalışan makinede yalnızca Oracle AI Database 26ai Free süreçleri görüldü.
- Çalışan makinenin Oracle home yolu:
  `/opt/oracle/product/26ai/dbhomeFree`
- Çalışan veritabanı `FREE`; aktif PDB ve servis `FREEPDB1/freepdb1`.
- Çalışan makinede 19c Oracle home veya ayrı 19c instance doğrulanmadı.
- DBeaver, SQL Developer ve VS Code için eski 19c bağlantısını gösterecek
  kayıtlı bağlantı dosyası çalışan makinede bulunmadı.

Parolalar incelenmedi, gösterilmedi veya dışa aktarılmadı.

## Host üzerinde bulunan eski VM'ler

| Aday | Sanal disk | Yaklaşık boyut | Durum |
|---|---|---:|---|
| `oracle-db` | `C:\Users\USER\VirtualBox VMs\oracle-db\oracle-db.vdi` | 20,5 GB | Kayıtlı; eski/ikincil ortam |
| `Oracle_DB` | `C:\Users\USER\VirtualBox VMs\Oracle_DB\Oracle_DB.vdi` | 6,86 GB | Kayıtlı; yarım kalmış ortam |

İki VM de kullanıcı onayıyla kaydedilip yalnızca açılış düzeyinde incelendi.
`Oracle_DB` Oracle Linux 9.3 ile açıldı. Kullanıcı, esas çalışmaların ana
`oracle` VM içindeki `cem` hesabında olduğunu; eski ortamlardan birinin boş veya
önemsiz, diğerindeki kurulumun ise yetersiz disk alanı nedeniyle yarım kaldığını
doğruladı.

## Güvenli sonraki adım

Eski VM'ler kapalı tutulmalı ve silinmemelidir. Proje çalışmaları ana `oracle`
VM üzerindeki `cem` hesabında ve 26ai `FREEPDB1` içinde sürdürülmelidir. Eski
ortamlardan veri kurtarma gereksinimi doğmadıkça ek inceleme yapılmasına ihtiyaç
yoktur.

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

## Host üzerinde bulunan 19c adayları

| Aday | Sanal disk | Yaklaşık boyut | Durum |
|---|---|---:|---|
| `oracle-db` | `C:\Users\USER\VirtualBox VMs\oracle-db\oracle-db.vdi` | 20,5 GB | VirtualBox'a kayıtlı değil |
| `Oracle_DB` | `C:\Users\USER\VirtualBox VMs\Oracle_DB\Oracle_DB.vdi` | 6,86 GB | VirtualBox'a kayıtlı değil |

Bu iki klasörün `.vbox` yapılandırmaları Oracle Linux türünü gösterir. Ancak
VM'ler başlatılmadan içlerindeki Oracle sürümü, CDB/PDB adları ve SH şemasının
konumu kesin olarak doğrulanamaz.

## Güvenli sonraki adım

Aday VM'lerden birini VirtualBox'a kaydetmek ve başlatmak sanal disk üzerinde
açılış günlükleri oluşturabileceği için kullanıcı onayı olmadan yapılmadı.
Onaydan sonra sırayla:

1. VM kayıt ve ağ ayarları doğrulanır.
2. Oracle sürümü ve çalışan instance'lar salt-okunur komutlarla belirlenir.
3. CDB/PDB listesi ve servis adları kontrol edilir.
4. Her PDB içinde SH kullanıcısı, hesap durumu, nesne ve tablo satır sayıları
   salt-okunur sorgularla envanterlenir.
5. Herhangi bir schema silme, taşıma veya yükseltme işlemi ayrı onaya bırakılır.

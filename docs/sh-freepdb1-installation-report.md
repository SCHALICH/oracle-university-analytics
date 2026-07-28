# Oracle 26ai FREEPDB1 — SH Kurulum ve Doğrulama Raporu

Kurulum tarihi: 27 Temmuz 2026

## Doğrulanan bağlantı

| Alan | Değer |
|---|---|
| Ortam | VirtualBox içindeki Oracle Linux |
| Veritabanı | Oracle AI Database 26ai Free 23.26.2.0.0 |
| CDB | FREE |
| PDB / servis | FREEPDB1 / freepdb1 |
| Açık mod | READ WRITE |
| Rol | PRIMARY |
| Host yönlendirmesi | 127.0.0.1:15210 → misafir 1521 |

Parolalar bu rapora veya Git deposuna yazılmamıştır.

## Kurulum öncesi durum

- Hedef container `FREEPDB1` olarak doğrulandı.
- SH kullanıcısı yoktu.
- SH nesnesi, tablo veya yarım kurulum izi bulunmadı.
- Kurulum `overwrite=NO` ile çalıştırıldı; beklenmedik mevcut şema durumunda
  kullanıcı silinmeyecekti.
- Kaynak, Oracle'ın resmî `oracle-samples/db-sample-schemas/sales_history`
  dosyalarıdır.
- SQLcl sürümü: 26.1.1.

## Kurulum sonucu

| Tablo | Satır |
|---|---:|
| CHANNELS | 5 |
| COSTS | 82.112 |
| COUNTRIES | 35 |
| CUSTOMERS | 55.500 |
| PRODUCTS | 72 |
| PROMOTIONS | 503 |
| SALES | 918.843 |
| TIMES | 1.826 |
| SUPPLEMENTARY_DEMOGRAPHICS | 4.500 |

Ek doğrulamalar:

- SH hesap durumu: `OPEN`
- Varsayılan tablespace: `USERS`
- 210 nesnenin tamamı: `VALID`
- 115 index partition'ının tamamı: `USABLE`
- Constraint'ler: 140 adet `ENABLED`
- Satış tarihi: 2019-01-01–2022-12-31, 48 ay
- Null satış tutarı: 0
- Sıfır veya negatif miktar: 0
- Resmî yükleme sırasında hatalı SALES satırı: 0

`NOT VALIDATED` görünen 16 constraint, resmî SH betiğinin bilinçli
`ENABLE NOVALIDATE` tanımlarıdır; devre dışı constraint yoktur.

## Karşılaşılan hatalar ve çözümleri

| Hata | Temel neden | Çözüm |
|---|---|---|
| ORA-12162 | SYSDBA ortamında ORACLE_SID eksikti | `ORACLE_SID=FREE` tanımlandı |
| ORA-01012 | SYSDBA bağlantısı komut satırında yanlış ayrıştırıldı | `/nolog` ve açık `CONNECT / AS SYSDBA` kullanıldı |
| ORA-01507 / ORA-01219 | Kontrol anında CDB henüz açılma aşamasındaydı | `READ WRITE` durumu beklenip tekrar doğrulandı |
| ORA-65011 | CDB kapalıyken FREEPDB1 katalogda erişilebilir değildi | CDB açıldıktan sonra container yeniden doğrulandı |
| ORA-01531 / ORA-65054 | CDB/PDB eşzamanlı olarak zaten açılmıştı | İdempotent durum kontrolü kullanıldı |
| ORA-20999 | SQLcl `ACCEPT ... HIDE` yönlendirilmiş girdiyi boş okudu | Üç ACCEPT satırı parametreli DEFINE olarak uyarlandı |
| SP2-0667 | SQL*Plus için ORACLE_HOME eksikti | Doğru 26ai ORACLE_HOME tanımlandı |

## Yeniden çalıştırma

Önce SYSDBA ile bağlanıp doğru container'ı seç:

```sql
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM DUAL;
```

Resmî SH klasöründe, projedeki otomasyon betiğini kullan:

```text
sql /nolog
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER = FREEPDB1;
@sh_install_automated.sql <SH_PASSWORD> USERS NO
```

`NO` seçeneği mevcut SH kullanıcısının silinmesini engeller. Var olan bir SH
şemasını yenilemek için `YES` kullanılmadan önce açık kullanıcı onayı alınmalıdır.

Canlı model veri setini dışa aktar:

```text
@01_monthly_sales_dataset.sql /istenen/yol/sh_monthly_sales_live.csv
```

Ardından:

```bash
python -m models.random_forest --dataset datasets/sh_monthly_sales_live.csv
python -m models.sarimax --dataset datasets/sh_monthly_sales_live.csv
python -m models.compare_models
```

## Canlı model sonuçları

| Model | Hedef seviyesi | MAPE |
|---|---|---:|
| Random Forest | Ay × ürün kategorisi × kanal | %7,40 |
| SARIMAX | Aylık toplam satış | %3,33 |

Modeller farklı hedef seviyelerinde çalıştığı için mutlak MAE/RMSE değerleri
bir kazanan seçmek amacıyla doğrudan karşılaştırılmamalıdır.

## 28 Temmuz 2026 canlı yeniden doğrulama

Ana `oracle` VM yeniden başlatıldıktan sonra:

- CDB `FREE`: `READ WRITE`, `PRIMARY`
- PDB `FREEPDB1`: `READ WRITE`, kısıtlı değil
- SH hesabı: `OPEN`, tablespace `USERS`
- Geçerli SH nesnesi: 210
- `SH.SALES`: 918.843 satır
- `FREEPDB1` açılış durumu: `SAVE STATE`, `OPEN`

Kanıt ekranı: `docs/evidence/freepdb1-sh-validation.png`.

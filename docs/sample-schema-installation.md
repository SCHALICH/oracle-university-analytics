# Oracle Sample Schema Kurulum Notları

## Kapsam

Projede HR, SH, OE, PM ve CO şemaları kullanılır. Kurulum dosyaları Oracle'ın
sample schemas paketinden alınır ve her şemanın kendi `*_install.sql` betiği
çalıştırılır.

## Güvenli kurulum akışı

1. Doğru CDB/PDB ve servis adına bağlanıldığını doğrula.
2. Sample schema paketini Oracle'ın resmî kaynağından indir.
3. Gerekli kullanıcı oluşturma yetkisine sahip hesapla PDB'ye bağlan.
4. İlgili `*_install.sql` dosyasını çalıştır.
5. Güçlü bir şema parolası ve uygun varsayılan tablespace seç.
6. Betik çıktısını ve oluşturulan log dosyasını kontrol et.
7. Kullanıcı, tablo ve satır sayısı kontrollerini çalıştır.

Oracle'ın 26ai dokümantasyonuna göre SH kurulum/kaldırma işlemi SQLcl, SQL
Developer veya VS Code Oracle SQL Developer eklentisiyle yapılmalıdır; SQL*Plus
bu işlem için kullanılmamalıdır.

## Doğrulama sorguları

```sql
SELECT username, account_status
FROM dba_users
WHERE username IN ('HR', 'SH', 'OE', 'PM', 'CO')
ORDER BY username;
```

Her şemaya bağlandıktan sonra:

```sql
SELECT table_name, num_rows
FROM user_tables
ORDER BY table_name;
```

## Sıfırlama

Sample schema kurulum betikleri mevcut aynı adlı kullanıcıyı kaldırmayı
önerebilir. Bu işlem mevcut veriyi siler; yeniden kurulumdan önce gerekli özel
değişiklikler ayrıca yedeklenmelidir.

## Resmî kaynaklar

- [Sample Schema installation](https://docs.oracle.com/en/database/oracle/oracle-database/26/comsc/installing-sample-schemas.html)
- [Sample Schema diagrams](https://docs.oracle.com/en/database/oracle/oracle-database/26/comsc/schema-diagrams.html)

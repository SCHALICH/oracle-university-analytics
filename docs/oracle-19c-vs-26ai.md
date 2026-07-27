# Oracle Database 19c ve Oracle AI Database 26ai

## Genel değerlendirme

Oracle Database 19c; SQL, PL/SQL, Multitenant, In-Memory ve kurumsal iş
yükleri için olgun bir temel sunar. Oracle AI Database 26ai ise Oracle'ın
sonraki uzun dönem destek sürümü olarak yapay zekâ, geliştirici üretkenliği ve
birleşik veri modeli yeteneklerini genişletir.

## Karşılaştırma

| Başlık | Oracle Database 19c | Oracle AI Database 26ai |
|---|---|---|
| Projedeki rol | Geleneksel SQL ve sample schema çalışmaları | Yeni nesil SQL, AI ve geliştirici özellikleri |
| İlişkisel SQL/PLSQL | Temel çalışma alanı | Geriye uyumlu temel çalışma alanı |
| Multitenant | CDB/PDB yönetimi | CDB/PDB yaklaşımı devam eder |
| JSON | SQL/PLSQL ve SODA desteği | Native JSON, JSON Relational Duality ve gelişmiş JSON özellikleri |
| Yapay zekâ | Harici araçlarla entegrasyon ve Oracle ML | AI Vector Search, Select AI ve genişletilmiş ML/AI araçları |
| Grafik | Ayrı/önceki graph yetenekleri | SQL Property Graph ve operasyonel graph analitiği |
| Geliştirici özellikleri | Klasik SQL, PL/SQL ve sürücüler | BOOLEAN, JSON duality, JavaScript prosedürleri ve yeni SQL özellikleri |

## 26ai için öne çıkan çalışma alanları

- Vektör veri tipi, vektör indeksleri ve benzerlik araması
- JSON Relational Duality Views
- SQL Property Graph
- Select AI ve doğal dil destekli sorgulama
- JSON Schema doğrulama
- Yeni SQL ve geliştirici üretkenliği özellikleri

## Proje açısından sonuç

19c ortamı sample schema, ilişkisel tasarım ve geleneksel raporlama için
referans ortamıdır. 26ai ortamı aynı çalışmaların uyumluluk kontrolüyle birlikte
vektör, JSON duality ve AI özelliklerini denemek için kullanılmalıdır. Üretim
geçişi değerlendirilirken kullanılan istemci sürücüleri, `COMPATIBLE` değeri,
deprecations/desupports listesi ve lisans koşulları ayrıca kontrol edilmelidir.

## Resmî kaynaklar

- [Oracle Database 19c Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/)
- [Oracle AI Database 26ai Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/index.html)
- [Oracle AI Database 26ai New Features](https://docs.oracle.com/en/database/oracle/oracle-database/26/nfcoa/all-nfg.html)
- [Oracle AI, ML and Analytics documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/ai.html)

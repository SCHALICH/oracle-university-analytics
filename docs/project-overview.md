# Proje Özeti

Oracle University Analytics, üniversite akademik süreçlerini ilişkisel bir
modelde birleştiren eğitim ve portföy projesidir. Temel kayıt işlemlerinin
yanında Oracle'a özgü ileri SQL özelliklerini ve Python tabanlı tahmin
çalışmasını aynı veri modeli üzerinde gösterir.

## Hedefler

- Akademik veriyi bütünlük kurallarıyla modellemek
- Başlangıçtan ileri seviyeye Oracle SQL örnekleri sunmak
- Bölüm, ders ve öğrenci performans raporları üretmek
- Not verileri üzerinde tekrar üretilebilir makine öğrenmesi akışı kurmak

## Modüller

| Modül | İçerik |
|---|---|
| Temel şema | 11 ilişkisel tablo, anahtarlar ve kontrol kısıtları |
| Örnek veri | Üniversite, bölüm, öğrenci, ders, kayıt ve not kayıtları |
| PL/SQL | Trigger, procedure, package ve cursor örnekleri |
| İleri SQL | CTE, analitik fonksiyon, MERGE, PIVOT, JSON, XML ve MODEL |
| Raporlama | Yönetici, bölüm, ders ve öğrenci performans raporları |
| Python | Random Forest ile öğrenci not tahmini |

## Kurulum akışı

`database/00_install.sql` temel şemayı, örnek veriyi, görünümü, indeksleri ve
PL/SQL nesnelerini doğru sırada kurar. İleri seviye örnek dosyalar eğitim
amacıyla ayrıca çalıştırılır.

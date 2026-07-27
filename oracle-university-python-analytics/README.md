# Python Analytics

Bu klasör, Oracle veritabanındaki not verilerini kullanarak Random Forest
regresyon modeli eğitir.

## Kurulum

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

Bağlantı bilgilerini kaynak koda yazmak yerine ortam değişkenleriyle sağlayın:

```powershell
$env:ORACLE_USER = "kullanici"
$env:ORACLE_PASSWORD = "parola"
$env:ORACLE_DSN = "localhost:1521/FREEPDB1"
```

## Çalıştırma

Bu klasörün içindeyken:

```powershell
python -m models.random_forest
```

Model ve metrik çıktıları `models/` klasörüne yazılır. Eğitim için en az 100
not kaydı gerekir.

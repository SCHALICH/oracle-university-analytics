"""Mevcut model çıktılarını tablo, grafik ve özet rapora dönüştürür."""

from __future__ import annotations

import json
from pathlib import Path

import joblib
import matplotlib.pyplot as plt
import pandas as pd

MODEL_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = MODEL_DIR / "outputs"


def export_feature_importance() -> pd.DataFrame:
    pipeline = joblib.load(MODEL_DIR / "random_forest.joblib")
    preprocessing = pipeline.named_steps["preprocessor"]
    model = pipeline.named_steps["model"]

    feature_names = preprocessing.get_feature_names_out()
    importance = (
        pd.DataFrame(
            {
                "feature": feature_names,
                "importance": model.feature_importances_,
            }
        )
        .sort_values("importance", ascending=False)
        .reset_index(drop=True)
    )
    importance.to_csv(
        OUTPUT_DIR / "random_forest_feature_importance.csv",
        index=False,
    )

    top = importance.head(15).sort_values("importance")
    fig, axis = plt.subplots(figsize=(10, 6))
    axis.barh(top["feature"], top["importance"], color="#2563EB")
    axis.set_title("Random Forest - En Önemli 15 Değişken")
    axis.set_xlabel("Önem skoru")
    axis.grid(axis="x", alpha=0.25)
    fig.tight_layout()
    fig.savefig(
        OUTPUT_DIR / "random_forest_feature_importance.png",
        dpi=180,
    )
    plt.close(fig)
    return importance


def export_forecast_plot() -> pd.DataFrame:
    forecast = pd.read_csv(
        MODEL_DIR / "sarimax_forecast.csv",
        parse_dates=["GRADE_MONTH"],
    )
    fig, axis = plt.subplots(figsize=(10, 5.5))
    axis.plot(
        forecast["GRADE_MONTH"],
        forecast["FORECAST_SCORE"],
        marker="o",
        linewidth=2.5,
        color="#0F766E",
        label="Tahmin",
    )
    axis.fill_between(
        forecast["GRADE_MONTH"],
        forecast["LOWER_BOUND"],
        forecast["UPPER_BOUND"],
        color="#5EEAD4",
        alpha=0.35,
        label="Güven aralığı",
    )
    axis.set_title("SARIMAX - Altı Aylık Ortalama Not Tahmini")
    axis.set_ylabel("Ortalama not")
    axis.grid(alpha=0.25)
    axis.legend()
    fig.autofmt_xdate()
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "sarimax_forecast.png", dpi=180)
    plt.close(fig)
    return forecast


def export_summary(importance: pd.DataFrame, forecast: pd.DataFrame) -> None:
    rf = json.loads(
        (MODEL_DIR / "random_forest_metrics.json").read_text(encoding="utf-8")
    )
    sarimax = json.loads(
        (MODEL_DIR / "sarimax_metrics.json").read_text(encoding="utf-8")
    )
    top_features = "\n".join(
        f"- `{row.feature}`: {row.importance:.4f}"
        for row in importance.head(10).itertuples()
    )
    forecast_rows = "\n".join(
        f"| {row.GRADE_MONTH:%Y-%m} | {row.FORECAST_SCORE:.2f} | {row.LOWER_BOUND:.2f}–{row.UPPER_BOUND:.2f} |"
        for row in forecast.itertuples()
    )
    report = f"""# Gerçek Model Sonuçları

Bu sonuçlar satış verisinden değil, üniversite veritabanındaki öğrenci notlarından
üretilmiştir. Random Forest tekil not skorunu, SARIMAX aylık ortalama notu modeller.

## Random Forest

- Toplam kayıt: **{rf['total_records']:,}**
- Eğitim / test: **{rf['train_records']:,} / {rf['test_records']:,}**
- MAE: **{rf['mae']:.2f}**
- RMSE: **{rf['rmse']:.2f}**
- R²: **{rf['r2']:.3f}**

R² değeri modelin tek başına güçlü bir nihai tahminleyici olmadığını gösterir.
Bu sonuç, daha zengin öğrenci geçmişi ve ders bağlamı değişkenleri için başlangıç
ölçütü olarak kullanılmalıdır.

### En önemli değişkenler

{top_features}

## SARIMAX

- Toplam dönem: **{sarimax['total_periods']} ay**
- Test dönemi: **{sarimax['test_periods']} ay**
- MAE: **{sarimax['mae']:.2f}**
- RMSE: **{sarimax['rmse']:.2f}**
- MAPE: **%{sarimax['mape']:.2f}**
- Model: **SARIMAX{tuple(sarimax['order'])} × {tuple(sarimax['seasonal_order'])}**

| Ay | Tahmin | Güven aralığı |
|---|---:|---:|
{forecast_rows}

SARIMAX kısa vadeli aylık ortalama not tahmininde Random Forest'tan farklı bir
soruyu yanıtlar. Bu nedenle iki modelin metrikleri doğrudan “kazanan model”
seçmek için değil, kullanım amacına göre değerlendirilmelidir.
"""
    (OUTPUT_DIR / "model-results.md").write_text(report, encoding="utf-8")


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    importance = export_feature_importance()
    forecast = export_forecast_plot()
    export_summary(importance, forecast)
    print(f"Çıktılar hazır: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()

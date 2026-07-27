"""Create a concise comparison from saved model metrics."""

from __future__ import annotations

import json

import pandas as pd

from models.data import OUTPUT_DIR


def load_metrics(filename: str) -> dict[str, object]:
    path = OUTPUT_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"Run the related model first: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    random_forest = load_metrics("random_forest_metrics.json")
    sarimax = load_metrics("sarimax_metrics.json")

    comparison = pd.DataFrame(
        [
            {
                "MODEL": random_forest["model"],
                "MAE": random_forest["mae"],
                "RMSE": random_forest["rmse"],
                "MAPE": random_forest["mape"],
                "TARGET_LEVEL": "Ay × ürün × kanal",
                "BEST_USE": "Category/channel and nonlinear drivers",
            },
            {
                "MODEL": sarimax["model"],
                "MAE": sarimax["mae"],
                "RMSE": sarimax["rmse"],
                "MAPE": sarimax["mape"],
                "TARGET_LEVEL": "Aylık toplam satış",
                "BEST_USE": "Aggregate monthly trend and seasonality",
            },
        ]
    )
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    comparison.to_csv(OUTPUT_DIR / "model_comparison.csv", index=False)

    report = [
        "# Model Karşılaştırması",
        "",
        comparison.to_markdown(index=False, floatfmt=".2f"),
        "",
        "Modeller farklı toplulaştırma seviyelerini tahmin ettiği için MAE ve "
        "RMSE değerleri doğrudan bir kazanan seçmek amacıyla karşılaştırılamaz. "
        "Her model kendi hedef seviyesinde değerlendirilmelidir.",
        "",
        "Random Forest kategori, kanal ve işlem özelliklerinin doğrusal olmayan "
        "etkilerini açıklamak için; SARIMAX ise toplam satış trendi, mevsimsellik "
        "ve ileri dönem tahmini için değerlendirilmelidir.",
    ]
    (OUTPUT_DIR / "model_comparison.md").write_text(
        "\n".join(report),
        encoding="utf-8",
    )
    print(comparison.to_string(index=False))


if __name__ == "__main__":
    main()

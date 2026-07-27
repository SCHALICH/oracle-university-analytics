"""Time-aware Random Forest sales model."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import joblib
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

from models.data import (
    DEFAULT_DATASET,
    OUTPUT_DIR,
    load_dataset,
    regression_metrics,
)

FEATURE_COLUMNS = [
    "CALENDAR_YEAR",
    "CALENDAR_MONTH_NUMBER",
    "PRODUCT_CATEGORY",
    "CHANNEL_DESC",
    "TOTAL_QUANTITY",
    "AVERAGE_UNIT_PRICE",
    "CUSTOMER_COUNT",
    "TRANSACTION_COUNT",
]
CATEGORICAL_COLUMNS = ["PRODUCT_CATEGORY", "CHANNEL_DESC"]
NUMERIC_COLUMNS = [
    column for column in FEATURE_COLUMNS if column not in CATEGORICAL_COLUMNS
]


def train_random_forest(
    dataset_path: Path = DEFAULT_DATASET,
    test_months: int = 3,
) -> dict[str, object]:
    """Train using all but the latest months and evaluate chronologically."""
    dataframe = load_dataset(dataset_path)
    months = dataframe["MONTH_START"].drop_duplicates().sort_values()
    if len(months) <= test_months:
        raise ValueError(
            f"At least {test_months + 1} distinct months are required."
        )

    cutoff = months.iloc[-test_months]
    train = dataframe[dataframe["MONTH_START"] < cutoff].copy()
    test = dataframe[dataframe["MONTH_START"] >= cutoff].copy()

    preprocessor = ColumnTransformer(
        [
            (
                "categorical",
                OneHotEncoder(handle_unknown="ignore"),
                CATEGORICAL_COLUMNS,
            ),
            ("numeric", "passthrough", NUMERIC_COLUMNS),
        ]
    )
    pipeline = Pipeline(
        [
            ("preprocessor", preprocessor),
            (
                "model",
                RandomForestRegressor(
                    n_estimators=400,
                    min_samples_leaf=2,
                    random_state=42,
                    n_jobs=-1,
                ),
            ),
        ]
    )
    pipeline.fit(train[FEATURE_COLUMNS], train["TOTAL_AMOUNT"])
    predictions = pipeline.predict(test[FEATURE_COLUMNS])
    metrics = regression_metrics(test["TOTAL_AMOUNT"], predictions)

    results = test[
        ["MONTH_START", "PRODUCT_CATEGORY", "CHANNEL_DESC", "TOTAL_AMOUNT"]
    ].copy()
    results["PREDICTED_AMOUNT"] = predictions
    results["ABSOLUTE_ERROR"] = (
        results["TOTAL_AMOUNT"] - results["PREDICTED_AMOUNT"]
    ).abs()

    encoder = pipeline.named_steps["preprocessor"].named_transformers_[
        "categorical"
    ]
    feature_names = list(
        encoder.get_feature_names_out(CATEGORICAL_COLUMNS)
    ) + NUMERIC_COLUMNS
    importance = pd.DataFrame(
        {
            "FEATURE": feature_names,
            "IMPORTANCE": pipeline.named_steps["model"].feature_importances_,
        }
    ).sort_values("IMPORTANCE", ascending=False)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    joblib.dump(pipeline, OUTPUT_DIR / "random_forest.joblib")
    results.to_csv(OUTPUT_DIR / "random_forest_predictions.csv", index=False)
    importance.to_csv(OUTPUT_DIR / "random_forest_importance.csv", index=False)

    summary = {
        "model": "Random Forest",
        "train_rows": int(len(train)),
        "test_rows": int(len(test)),
        "test_months": int(test_months),
        **metrics,
    }
    (OUTPUT_DIR / "random_forest_metrics.json").write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    top_features = importance.head(15).sort_values("IMPORTANCE")
    figure, axis = plt.subplots(figsize=(10, 6))
    axis.barh(top_features["FEATURE"], top_features["IMPORTANCE"])
    axis.set_title("Random Forest Feature Importance")
    axis.set_xlabel("Importance")
    figure.tight_layout()
    figure.savefig(
        OUTPUT_DIR / "random_forest_feature_importance.png",
        dpi=160,
    )
    plt.close(figure)

    return {"metrics": summary, "results": results, "importance": importance}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    parser.add_argument("--test-months", type=int, default=3)
    arguments = parser.parse_args()
    outcome = train_random_forest(arguments.dataset, arguments.test_months)
    print(json.dumps(outcome["metrics"], indent=2))


if __name__ == "__main__":
    main()

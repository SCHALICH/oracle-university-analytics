"""SARIMAX monthly sales forecasting."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from statsmodels.tsa.statespace.sarimax import SARIMAX

from models.data import (
    DEFAULT_DATASET,
    OUTPUT_DIR,
    aggregate_monthly,
    load_dataset,
    regression_metrics,
)


def train_sarimax(
    dataset_path: Path = DEFAULT_DATASET,
    test_months: int = 3,
    forecast_months: int = 3,
) -> dict[str, object]:
    """Evaluate on the latest months, then forecast from all observations."""
    series = aggregate_monthly(load_dataset(dataset_path))
    if len(series) < 24 + test_months:
        raise ValueError(
            "SARIMAX requires at least 24 training months plus test months."
        )

    train = series.iloc[:-test_months]
    test = series.iloc[-test_months:]
    evaluation_model = SARIMAX(
        train,
        order=(1, 1, 1),
        seasonal_order=(1, 1, 1, 12),
        enforce_stationarity=False,
        enforce_invertibility=False,
    ).fit(disp=False)
    test_prediction = evaluation_model.get_forecast(test_months)
    predicted_mean = test_prediction.predicted_mean
    metrics = regression_metrics(test, predicted_mean)

    final_model = SARIMAX(
        series,
        order=(1, 1, 1),
        seasonal_order=(1, 1, 1, 12),
        enforce_stationarity=False,
        enforce_invertibility=False,
    ).fit(disp=False)
    future = final_model.get_forecast(forecast_months)
    confidence = future.conf_int()
    forecast = pd.DataFrame(
        {
            "MONTH_START": future.predicted_mean.index,
            "PREDICTED_AMOUNT": future.predicted_mean.values,
            "LOWER_95": confidence.iloc[:, 0].values,
            "UPPER_95": confidence.iloc[:, 1].values,
        }
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    final_model.save(OUTPUT_DIR / "sarimax_results.pkl")
    forecast.to_csv(OUTPUT_DIR / "sarimax_forecast.csv", index=False)

    summary = {
        "model": "SARIMAX",
        "observed_months": len(series),
        "test_months": int(test_months),
        "forecast_months": int(forecast_months),
        "order": [1, 1, 1],
        "seasonal_order": [1, 1, 1, 12],
        **metrics,
    }
    (OUTPUT_DIR / "sarimax_metrics.json").write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    figure, axis = plt.subplots(figsize=(11, 6))
    axis.plot(series.index, series.values, label="Observed")
    axis.plot(
        forecast["MONTH_START"],
        forecast["PREDICTED_AMOUNT"],
        marker="o",
        label="3-month forecast",
    )
    axis.fill_between(
        forecast["MONTH_START"],
        forecast["LOWER_95"],
        forecast["UPPER_95"],
        alpha=0.2,
        label="95% confidence interval",
    )
    axis.set_title("SH Monthly Sales SARIMAX Forecast")
    axis.set_ylabel("Sales amount")
    axis.legend()
    figure.tight_layout()
    figure.savefig(OUTPUT_DIR / "sarimax_forecast.png", dpi=160)
    plt.close(figure)

    return {"metrics": summary, "forecast": forecast}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    parser.add_argument("--test-months", type=int, default=3)
    parser.add_argument("--forecast-months", type=int, default=3)
    arguments = parser.parse_args()
    outcome = train_sarimax(
        arguments.dataset,
        arguments.test_months,
        arguments.forecast_months,
    )
    print(json.dumps(outcome["metrics"], indent=2))


if __name__ == "__main__":
    main()

import json
import math
import warnings
from pathlib import Path

import joblib
import pandas as pd

from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
)
from statsmodels.tsa.statespace.sarimax import SARIMAX

from config.database import get_connection


warnings.filterwarnings("ignore")


MODEL_DIR = Path(__file__).resolve().parent
MODEL_PATH = MODEL_DIR / "sarimax.joblib"
METRICS_PATH = MODEL_DIR / "sarimax_metrics.json"
FORECAST_PATH = MODEL_DIR / "sarimax_forecast.csv"


def load_time_series():
    query = """
        SELECT
            TRUNC(g.graded_at, 'MM') AS grade_month,
            ROUND(AVG(g.score), 4) AS average_score,
            COUNT(*) AS grade_count
        FROM grades g
        WHERE g.graded_at IS NOT NULL
        GROUP BY TRUNC(g.graded_at, 'MM')
        ORDER BY grade_month
    """

    connection = get_connection()

    try:
        dataframe = pd.read_sql(
            query,
            connection,
        )
    finally:
        connection.close()

    dataframe.columns = [
        column.upper()
        for column in dataframe.columns
    ]

    if dataframe.empty:
        raise ValueError(
            "SARIMAX modeli için zaman serisi verisi bulunamadı."
        )

    dataframe["GRADE_MONTH"] = pd.to_datetime(
        dataframe["GRADE_MONTH"]
    )

    dataframe = (
        dataframe
        .sort_values("GRADE_MONTH")
        .set_index("GRADE_MONTH")
    )

    complete_index = pd.date_range(
        start=dataframe.index.min(),
        end=dataframe.index.max(),
        freq="MS",
    )

    dataframe = dataframe.reindex(
        complete_index
    )

    dataframe.index.name = "GRADE_MONTH"

    dataframe["AVERAGE_SCORE"] = (
        dataframe["AVERAGE_SCORE"]
        .interpolate(method="linear")
        .ffill()
        .bfill()
    )

    dataframe["GRADE_COUNT"] = (
        dataframe["GRADE_COUNT"]
        .fillna(0)
        .astype(int)
    )

    return dataframe


def calculate_mape(actual, predicted):
    actual_series = pd.Series(actual).reset_index(drop=True)
    predicted_series = pd.Series(predicted).reset_index(drop=True)

    non_zero_mask = actual_series != 0

    if not non_zero_mask.any():
        return None

    percentage_errors = (
        (
            actual_series[non_zero_mask]
            - predicted_series[non_zero_mask]
        ).abs()
        / actual_series[non_zero_mask].abs()
    )

    return float(
        percentage_errors.mean() * 100
    )


def train_sarimax(
    forecast_periods=6,
    test_periods=6,
):
    dataframe = load_time_series()

    series = dataframe["AVERAGE_SCORE"].astype(float)

    if len(series) < 18:
        raise ValueError(
            "SARIMAX için en az 18 aylık veri önerilir."
        )

    if test_periods >= len(series):
        raise ValueError(
            "Test dönemi toplam veri sayısından küçük olmalıdır."
        )

    train_series = series.iloc[:-test_periods]
    test_series = series.iloc[-test_periods:]

    model = SARIMAX(
        train_series,
        order=(1, 1, 1),
        seasonal_order=(1, 0, 1, 12),
        enforce_stationarity=False,
        enforce_invertibility=False,
    )

    fitted_model = model.fit(
        disp=False,
    )

    test_forecast_result = fitted_model.get_forecast(
        steps=test_periods
    )

    test_predictions = (
        test_forecast_result
        .predicted_mean
    )

    test_predictions.index = test_series.index

    mae = mean_absolute_error(
        test_series,
        test_predictions,
    )

    mse = mean_squared_error(
        test_series,
        test_predictions,
    )

    rmse = math.sqrt(mse)

    mape = calculate_mape(
        test_series,
        test_predictions,
    )

    test_results = pd.DataFrame(
        {
            "GRADE_MONTH": test_series.index,
            "ACTUAL_SCORE": test_series.values,
            "PREDICTED_SCORE": test_predictions.values,
        }
    )

    test_results["ABSOLUTE_ERROR"] = (
        test_results["ACTUAL_SCORE"]
        - test_results["PREDICTED_SCORE"]
    ).abs()

    final_model = SARIMAX(
        series,
        order=(1, 1, 1),
        seasonal_order=(1, 0, 1, 12),
        enforce_stationarity=False,
        enforce_invertibility=False,
    )

    final_fitted_model = final_model.fit(
        disp=False,
    )

    future_result = final_fitted_model.get_forecast(
        steps=forecast_periods
    )

    future_mean = future_result.predicted_mean

    future_confidence = (
        future_result.conf_int(alpha=0.05)
    )

    future_index = pd.date_range(
        start=(
            series.index.max()
            + pd.offsets.MonthBegin(1)
        ),
        periods=forecast_periods,
        freq="MS",
    )

    future_mean.index = future_index
    future_confidence.index = future_index

    forecast_dataframe = pd.DataFrame(
        {
            "GRADE_MONTH": future_index,
            "FORECAST_SCORE": future_mean.values,
            "LOWER_BOUND": future_confidence.iloc[:, 0].values,
            "UPPER_BOUND": future_confidence.iloc[:, 1].values,
        }
    )

    forecast_dataframe["FORECAST_SCORE"] = (
        forecast_dataframe["FORECAST_SCORE"]
        .clip(lower=0, upper=100)
    )

    forecast_dataframe["LOWER_BOUND"] = (
        forecast_dataframe["LOWER_BOUND"]
        .clip(lower=0, upper=100)
    )

    forecast_dataframe["UPPER_BOUND"] = (
        forecast_dataframe["UPPER_BOUND"]
        .clip(lower=0, upper=100)
    )

    metrics = {
        "total_periods": int(len(series)),
        "train_periods": int(len(train_series)),
        "test_periods": int(len(test_series)),
        "forecast_periods": int(forecast_periods),
        "mae": float(mae),
        "mse": float(mse),
        "rmse": float(rmse),
        "mape": (
            float(mape)
            if mape is not None
            else None
        ),
        "order": [1, 1, 1],
        "seasonal_order": [1, 0, 1, 12],
        "last_observation_month": (
            series.index.max().strftime("%Y-%m-%d")
        ),
    }

    joblib.dump(
        final_fitted_model,
        MODEL_PATH,
    )

    with open(
        METRICS_PATH,
        "w",
        encoding="utf-8",
    ) as metrics_file:
        json.dump(
            metrics,
            metrics_file,
            indent=4,
        )

    forecast_dataframe.to_csv(
        FORECAST_PATH,
        index=False,
    )

    return (
        final_fitted_model,
        metrics,
        test_results,
        forecast_dataframe,
        dataframe,
    )


def main():
    (
        _,
        metrics,
        test_results,
        forecast_dataframe,
        time_series_dataframe,
    ) = train_sarimax(
        forecast_periods=6,
        test_periods=6,
    )

    print()
    print("SARIMAX Model Results")
    print("-" * 40)
    print(
        f"Total periods    : "
        f"{metrics['total_periods']}"
    )
    print(
        f"Train periods    : "
        f"{metrics['train_periods']}"
    )
    print(
        f"Test periods     : "
        f"{metrics['test_periods']}"
    )
    print(
        f"Forecast periods : "
        f"{metrics['forecast_periods']}"
    )
    print(
        f"MAE              : "
        f"{metrics['mae']:.4f}"
    )
    print(
        f"MSE              : "
        f"{metrics['mse']:.4f}"
    )
    print(
        f"RMSE             : "
        f"{metrics['rmse']:.4f}"
    )

    if metrics["mape"] is not None:
        print(
            f"MAPE             : "
            f"{metrics['mape']:.4f}%"
        )

    print()
    print("Historical Time Series")
    print("-" * 40)
    print(
        time_series_dataframe
        .reset_index()
        .tail(10)
        .to_string(index=False)
    )

    print()
    print("Test Predictions")
    print("-" * 40)
    print(
        test_results.to_string(
            index=False
        )
    )

    print()
    print("Future Forecast")
    print("-" * 40)
    print(
        forecast_dataframe.to_string(
            index=False
        )
    )

    print()
    print(f"Model saved    : {MODEL_PATH}")
    print(f"Metrics saved  : {METRICS_PATH}")
    print(f"Forecast saved : {FORECAST_PATH}")


if __name__ == "__main__":
    main()

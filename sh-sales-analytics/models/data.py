"""Shared dataset loading and metric helpers."""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_DATASET = PROJECT_ROOT / "datasets" / "sh_monthly_sales.csv"
OUTPUT_DIR = PROJECT_ROOT / "outputs"

REQUIRED_COLUMNS = {
    "MONTH_START",
    "CALENDAR_YEAR",
    "CALENDAR_MONTH_NUMBER",
    "PRODUCT_CATEGORY",
    "CHANNEL_DESC",
    "TOTAL_QUANTITY",
    "TOTAL_AMOUNT",
    "AVERAGE_UNIT_PRICE",
    "CUSTOMER_COUNT",
    "TRANSACTION_COUNT",
}


def load_dataset(path: Path = DEFAULT_DATASET) -> pd.DataFrame:
    """Load and validate the monthly SH sales export."""
    if not path.exists():
        raise FileNotFoundError(
            f"Dataset not found: {path}. Run sql/01_monthly_sales_dataset.sql."
        )

    dataframe = pd.read_csv(path)
    dataframe.columns = [column.strip().upper() for column in dataframe.columns]

    missing = sorted(REQUIRED_COLUMNS - set(dataframe.columns))
    if missing:
        raise ValueError(f"Dataset is missing required columns: {missing}")

    dataframe["MONTH_START"] = pd.to_datetime(
        dataframe["MONTH_START"],
        errors="coerce",
    )

    numeric_columns = [
        "CALENDAR_YEAR",
        "CALENDAR_MONTH_NUMBER",
        "TOTAL_QUANTITY",
        "TOTAL_AMOUNT",
        "AVERAGE_UNIT_PRICE",
        "CUSTOMER_COUNT",
        "TRANSACTION_COUNT",
    ]
    for column in numeric_columns:
        dataframe[column] = pd.to_numeric(dataframe[column], errors="coerce")

    dataframe = dataframe.dropna(
        subset=[
            "MONTH_START",
            "PRODUCT_CATEGORY",
            "CHANNEL_DESC",
            *numeric_columns,
        ]
    ).copy()

    if dataframe.empty:
        raise ValueError("Dataset has no usable rows after validation.")
    if (dataframe["TOTAL_AMOUNT"] < 0).any():
        raise ValueError("TOTAL_AMOUNT contains negative values.")
    if (dataframe["TOTAL_QUANTITY"] <= 0).any():
        raise ValueError("TOTAL_QUANTITY contains non-positive values.")

    return dataframe.sort_values(
        ["MONTH_START", "PRODUCT_CATEGORY", "CHANNEL_DESC"]
    ).reset_index(drop=True)


def aggregate_monthly(dataframe: pd.DataFrame) -> pd.Series:
    """Aggregate category/channel rows to a continuous monthly total series."""
    series = (
        dataframe.groupby("MONTH_START")["TOTAL_AMOUNT"]
        .sum()
        .sort_index()
        .asfreq("MS")
    )
    if series.isna().any():
        series = series.interpolate(method="linear").ffill().bfill()
    return series


def regression_metrics(
    actual: pd.Series | np.ndarray,
    predicted: pd.Series | np.ndarray,
) -> dict[str, float]:
    """Return comparable forecasting metrics."""
    actual_array = np.asarray(actual, dtype=float)
    predicted_array = np.asarray(predicted, dtype=float)
    error = actual_array - predicted_array

    mae = float(np.mean(np.abs(error)))
    rmse = float(math.sqrt(np.mean(np.square(error))))
    nonzero = actual_array != 0
    mape = (
        float(
            np.mean(
                np.abs(error[nonzero] / actual_array[nonzero])
            )
            * 100
        )
        if nonzero.any()
        else float("nan")
    )
    return {"mae": mae, "rmse": rmse, "mape": mape}

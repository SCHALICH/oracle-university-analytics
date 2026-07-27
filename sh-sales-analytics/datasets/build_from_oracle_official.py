"""Oracle'ın resmi SH sales.csv dosyasından model veri seti üretir."""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd


OUTPUT_PATH = Path(__file__).resolve().parent / "sh_monthly_sales.csv"


def build_dataset(source: Path, output: Path = OUTPUT_PATH) -> pd.DataFrame:
    required = {
        "PROD_ID",
        "CUST_ID",
        "TIME_ID",
        "CHANNEL_ID",
        "QUANTITY_SOLD",
        "AMOUNT_SOLD",
    }
    monthly_parts: list[pd.DataFrame] = []

    for chunk in pd.read_csv(source, chunksize=100_000):
        chunk.columns = [column.strip().upper() for column in chunk.columns]
        missing = required - set(chunk.columns)
        if missing:
            raise ValueError(f"Kaynak dosyada eksik sütunlar: {sorted(missing)}")

        chunk["TIME_ID"] = pd.to_datetime(chunk["TIME_ID"], errors="coerce")
        chunk["MONTH_START"] = chunk["TIME_ID"].dt.to_period("M").dt.to_timestamp()
        chunk["QUANTITY_SOLD"] = pd.to_numeric(
            chunk["QUANTITY_SOLD"], errors="coerce"
        )
        chunk["AMOUNT_SOLD"] = pd.to_numeric(
            chunk["AMOUNT_SOLD"], errors="coerce"
        )
        chunk = chunk.dropna(
            subset=[
                "MONTH_START",
                "PROD_ID",
                "CUST_ID",
                "CHANNEL_ID",
                "QUANTITY_SOLD",
                "AMOUNT_SOLD",
            ]
        )

        grouped = (
            chunk.groupby(
                ["MONTH_START", "PROD_ID", "CHANNEL_ID"],
                as_index=False,
            )
            .agg(
                TOTAL_QUANTITY=("QUANTITY_SOLD", "sum"),
                TOTAL_AMOUNT=("AMOUNT_SOLD", "sum"),
                CUSTOMER_COUNT=("CUST_ID", "nunique"),
                TRANSACTION_COUNT=("CUST_ID", "size"),
            )
        )
        monthly_parts.append(grouped)

    dataset = (
        pd.concat(monthly_parts, ignore_index=True)
        .groupby(["MONTH_START", "PROD_ID", "CHANNEL_ID"], as_index=False)
        .agg(
            TOTAL_QUANTITY=("TOTAL_QUANTITY", "sum"),
            TOTAL_AMOUNT=("TOTAL_AMOUNT", "sum"),
            CUSTOMER_COUNT=("CUSTOMER_COUNT", "sum"),
            TRANSACTION_COUNT=("TRANSACTION_COUNT", "sum"),
        )
    )
    dataset["CALENDAR_YEAR"] = dataset["MONTH_START"].dt.year
    dataset["CALENDAR_MONTH_NUMBER"] = dataset["MONTH_START"].dt.month
    dataset["PRODUCT_CATEGORY"] = dataset["PROD_ID"].map(
        lambda value: f"PRODUCT_{int(value)}"
    )
    dataset["CHANNEL_DESC"] = dataset["CHANNEL_ID"].map(
        lambda value: f"CHANNEL_{int(value)}"
    )
    dataset["AVERAGE_UNIT_PRICE"] = (
        dataset["TOTAL_AMOUNT"] / dataset["TOTAL_QUANTITY"]
    )

    columns = [
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
    ]
    dataset = dataset[columns].sort_values(
        ["MONTH_START", "PRODUCT_CATEGORY", "CHANNEL_DESC"]
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    dataset.to_csv(output, index=False)
    return dataset


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "source",
        type=Path,
        help="Oracle db-sample-schemas/sales_history/sales.csv yolu",
    )
    parser.add_argument("--output", type=Path, default=OUTPUT_PATH)
    args = parser.parse_args()
    dataset = build_dataset(args.source, args.output)
    print(
        f"{len(dataset):,} satır, "
        f"{dataset['MONTH_START'].nunique()} ay: {args.output}"
    )


if __name__ == "__main__":
    main()

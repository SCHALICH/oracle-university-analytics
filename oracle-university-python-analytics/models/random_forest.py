import json
import math
from pathlib import Path

import joblib
import pandas as pd
from config.database import get_connection
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

PROJECT_ROOT = Path(__file__).resolve().parent.parent
MODEL_DIR = PROJECT_ROOT / "models"


def load_training_data() -> pd.DataFrame:
    connection = get_connection()

    query = """
    SELECT
        s.department_id,
        s.enrollment_year,
        s.status AS student_status,
        e.attendance_rate,
        e.enrollment_status,
        c.credits,
        c.course_level,
        c.status AS course_status,
        ex.exam_type,
        ex.maximum_score,
        ex.weight_percentage,
        g.score
    FROM grades g
    JOIN enrollments e
        ON g.enrollment_id = e.enrollment_id
    JOIN students s
        ON e.student_id = s.student_id
    JOIN course_offerings co
        ON e.offering_id = co.offering_id
    JOIN courses c
        ON co.course_id = c.course_id
    JOIN exams ex
        ON g.exam_id = ex.exam_id
    WHERE g.score IS NOT NULL
    """

    try:
        return pd.read_sql(query, connection)
    finally:
        connection.close()


def prepare_data(dataframe: pd.DataFrame):
    target_column = "SCORE"

    feature_columns = [
        "DEPARTMENT_ID",
        "ENROLLMENT_YEAR",
        "STUDENT_STATUS",
        "ATTENDANCE_RATE",
        "ENROLLMENT_STATUS",
        "CREDITS",
        "COURSE_LEVEL",
        "COURSE_STATUS",
        "EXAM_TYPE",
        "MAXIMUM_SCORE",
        "WEIGHT_PERCENTAGE",
    ]

    model_df = dataframe[feature_columns + [target_column]].copy()

    numeric_columns = [
        "DEPARTMENT_ID",
        "ENROLLMENT_YEAR",
        "ATTENDANCE_RATE",
        "CREDITS",
        "COURSE_LEVEL",
        "MAXIMUM_SCORE",
        "WEIGHT_PERCENTAGE",
    ]

    categorical_columns = [
        "STUDENT_STATUS",
        "ENROLLMENT_STATUS",
        "COURSE_STATUS",
        "EXAM_TYPE",
    ]

    for column in numeric_columns:
        model_df[column] = pd.to_numeric(
            model_df[column],
            errors="coerce",
        )

    model_df[target_column] = pd.to_numeric(
        model_df[target_column],
        errors="coerce",
    )

    for column in categorical_columns:
        model_df[column] = (
            model_df[column]
            .fillna("UNKNOWN")
            .astype(str)
        )

    model_df = model_df.dropna(
        subset=numeric_columns + [target_column]
    )

    x = model_df[feature_columns]
    y = model_df[target_column]

    return x, y, numeric_columns, categorical_columns


def train_model():
    dataframe = load_training_data()

    if dataframe.empty:
        raise ValueError("Oracle sorgusu eğitim verisi döndürmedi.")

    x, y, numeric_columns, categorical_columns = prepare_data(
        dataframe
    )

    if len(x) < 100:
        raise ValueError(
            f"Model eğitimi için veri yetersiz. "
            f"Mevcut kayıt sayısı: {len(x)}"
        )

    x_train, x_test, y_train, y_test = train_test_split(
        x,
        y,
        test_size=0.20,
        random_state=42,
    )

    preprocessor = ColumnTransformer(
        transformers=[
            (
                "categorical",
                OneHotEncoder(
                    handle_unknown="ignore",
                    sparse_output=False,
                ),
                categorical_columns,
            ),
            (
                "numeric",
                "passthrough",
                numeric_columns,
            ),
        ]
    )

    model = RandomForestRegressor(
        n_estimators=200,
        max_depth=None,
        min_samples_split=2,
        min_samples_leaf=1,
        random_state=42,
        n_jobs=-1,
    )

    pipeline = Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("model", model),
        ]
    )

    pipeline.fit(x_train, y_train)
    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    joblib.dump(pipeline, MODEL_DIR / "random_forest.joblib")
    predictions = pipeline.predict(x_test)
    encoder = (
        pipeline.named_steps["preprocessor"]
        .named_transformers_["categorical"]
    )

    encoded_features = encoder.get_feature_names_out(
        categorical_columns
    )

    feature_names = list(encoded_features) + numeric_columns

    importances = (
        pipeline.named_steps["model"]
        .feature_importances_
    )

    importance_df = (
        pd.DataFrame(
            {
                "Feature": feature_names,
                "Importance": importances,
            }
        )
        .sort_values(
            "Importance",
            ascending=False,
        )
        .reset_index(drop=True)
    )

    mae = mean_absolute_error(y_test, predictions)
    mse = mean_squared_error(y_test, predictions)
    rmse = math.sqrt(mse)
    r2 = r2_score(y_test, predictions)

    metrics_data = {
        "total_records": len(x),
        "train_records": len(x_train),
        "test_records": len(x_test),
        "mae": float(mae),
        "mse": float(mse),
        "rmse": float(rmse),
        "r2": float(r2),
    }

    with open(
        MODEL_DIR / "random_forest_metrics.json",
        "w",
        encoding="utf-8",
    ) as metrics_file:
        json.dump(metrics_data, metrics_file, indent=4)

    results = pd.DataFrame(
        {
            "ACTUAL_SCORE": y_test.reset_index(drop=True),
            "PREDICTED_SCORE": predictions,
        }
    )

    results["ABSOLUTE_ERROR"] = (
        results["ACTUAL_SCORE"]
        - results["PREDICTED_SCORE"]
    ).abs()

    metrics = {
        "record_count": len(x),
        "train_count": len(x_train),
        "test_count": len(x_test),
        "mae": mae,
        "mse": mse,
        "rmse": rmse,
        "r2": r2,
    }

    return pipeline, metrics, results, importance_df

def main():
    _, metrics, results, importance_df = train_model()

    print("\nRandom Forest Model Results")
    print("-" * 35)
    print(f"Total records : {metrics['record_count']}")
    print(f"Train records : {metrics['train_count']}")
    print(f"Test records  : {metrics['test_count']}")
    print(f"MAE           : {metrics['mae']:.4f}")
    print(f"MSE           : {metrics['mse']:.4f}")
    print(f"RMSE          : {metrics['rmse']:.4f}")
    print(f"R² Score      : {metrics['r2']:.4f}")

    print("\nSample Predictions")
    print("-" * 35)
    print(results.head(10).to_string(index=False))
    print("\nFeature Importance")
    print("-" * 35)
    print(importance_df.to_string(index=False))

if __name__ == "__main__":
    main()

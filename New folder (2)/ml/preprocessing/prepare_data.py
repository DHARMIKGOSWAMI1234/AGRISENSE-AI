import os
import pandas as pd
from ml.datasets.synthetic_generator import generate_synthetic_sessions

def prepare_dataset(raw_csv_path: str = "ml/datasets/synthetic_interactions.csv", cleaned_csv_path: str = "ml/datasets/cleaned_interactions.csv"):
    """
    Validates, cleans, and sanitizes dataset records.
    """
    if not os.path.exists(raw_csv_path):
        generate_synthetic_sessions(output_path=raw_csv_path)

    df = pd.read_csv(raw_csv_path)
    
    # 1. Validation checks
    assert "patient_id" in df.columns, "Missing patient_id column"
    assert "target_action" in df.columns, "Missing target_action label"
    
    # 2. Handle missing or extreme values
    df = df.dropna()
    df = df[(df["accuracy"] >= 0.0) & (df["accuracy"] <= 1.0)]
    df = df[(df["current_difficulty"] >= 1) & (df["current_difficulty"] <= 10)]
    df = df[df["duration_ms" if "duration_ms" in df.columns else "response_time_ms"] > 0]
    
    os.makedirs(os.path.dirname(cleaned_csv_path), exist_ok=True)
    df.to_csv(cleaned_csv_path, index=False)
    print(f"Dataset sanitized and prepared: {len(df)} rows saved to {cleaned_csv_path}")
    return df

if __name__ == "__main__":
    prepare_dataset()

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

FEATURE_COLUMNS = [
    "current_difficulty",
    "accuracy",
    "error_count",
    "hints_used",
    "response_time_ms",
    "completion_rate"
]

def extract_features_and_labels(df: pd.DataFrame):
    """
    Extracts numerical feature vectors and multiclass targets.
    """
    X = df[FEATURE_COLUMNS].copy()
    y = df["target_action"].values
    groups = df["patient_id"].values # For leakage-free GroupKFold
    return X, y, groups

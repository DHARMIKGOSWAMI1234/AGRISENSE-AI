import os
import joblib
import pandas as pd
from sklearn.model_selection import GroupKFold, cross_val_score
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from ml.feature_engineering.extract_features import extract_features_and_labels
from ml.preprocessing.prepare_data import prepare_dataset

def train_and_select_model(data_path: str = "ml/datasets/cleaned_interactions.csv", model_out_dir: str = "ml/models/registry"):
    """
    Trains baseline and candidate models using GroupKFold patient splitting.
    Saves best model and metadata.
    """
    if not os.path.exists(data_path):
        prepare_dataset()

    df = pd.read_csv(data_path)
    X, y, groups = extract_features_and_labels(df)

    gkf = GroupKFold(n_splits=5)

    models = {
        "LogisticRegression_Baseline": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", LogisticRegression(max_iter=1000, random_state=42))
        ]),
        "RandomForest_Classifier": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", RandomForestClassifier(n_estimators=100, max_depth=6, random_state=42))
        ]),
        "GradientBoosting_Classifier": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", GradientBoostingClassifier(n_estimators=100, max_depth=4, random_state=42))
        ])
    }

    results = {}
    print("\n--- Model Training & Cross-Validation (GroupKFold by Patient ID) ---")
    for name, model in models.items():
        scores = cross_val_score(model, X, y, groups=groups, cv=gkf, scoring="f1_macro")
        mean_score = scores.mean()
        std_score = scores.std()
        results[name] = (mean_score, model)
        print(f"[{name}] Macro F1 Score: {mean_score:.4f} (+/- {std_score:.4f})")

    # Select best model
    best_name = max(results, key=lambda k: results[k][0])
    best_score, best_model = results[best_name]
    print(f"\nBest Model Selected: {best_name} (Macro F1: {best_score:.4f})")

    # Train on full dataset
    best_model.fit(X, y)

    os.makedirs(model_out_dir, exist_ok=True)
    model_path = os.path.join(model_out_dir, "smriti_adaptive_model.joblib")
    joblib.dump({
        "model": best_model,
        "model_name": best_name,
        "macro_f1": best_score,
        "version": "v1.0.0"
    }, model_path)
    print(f"Exported serialized model artifact to: {model_path}")

    return best_model, best_name, best_score

if __name__ == "__main__":
    train_and_select_model()

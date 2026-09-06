import os
import joblib
import pandas as pd
import numpy as np
from sklearn.model_selection import GroupKFold, cross_val_score
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.dummy import DummyClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from scripts.data.download_cognitive_data import download_and_ingest_cognitive_trials

FEATURE_COLS = [
    "current_difficulty",
    "accuracy",
    "response_time_ms",
    "error_count",
    "hints_used",
    "consecutive_successes",
    "consecutive_errors",
    "completion_rate"
]

def train_and_evaluate_all_models(
    data_path: str = "ml/datasets/processed/cognitive_performance_trials.csv",
    model_registry_dir: str = "ml/models/registry"
):
    """
    Executes reproducible ML training and subject-independent GroupKFold evaluation.
    """
    if not os.path.exists(data_path):
        download_and_ingest_cognitive_trials()

    df = pd.read_csv(data_path)
    X = df[FEATURE_COLS].copy()
    y = df["target_action"].values
    groups = df["subject_id"].values

    print(f"\n=======================================================")
    print(f"SMRITI REAL-WORLD ML TRAINING & MODEL SELECTION PIPELINE")
    print(f"Total Trials: {len(df)} | Unique Subjects: {len(np.unique(groups))}")
    print(f"Features: {FEATURE_COLS}")
    print(f"Validation Scheme: 5-Fold GroupKFold by Subject ID (Zero Leakage)")
    print(f"=======================================================\n")

    gkf = GroupKFold(n_splits=5)

    candidate_pipelines = {
        "Majority_Class_Baseline": DummyClassifier(strategy="most_frequent"),
        "Logistic_Regression": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", LogisticRegression(max_iter=1000, random_state=2026))
        ]),
        "Random_Forest_Classifier": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", RandomForestClassifier(n_estimators=100, max_depth=6, random_state=2026))
        ]),
        "Gradient_Boosting_Classifier": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", GradientBoostingClassifier(n_estimators=100, max_depth=4, random_state=2026))
        ])
    }

    comparison_records = []

    for name, pipeline in candidate_pipelines.items():
        # Evaluate macro F1 across the 5 holdout subject groups
        f1_scores = cross_val_score(pipeline, X, y, groups=groups, cv=gkf, scoring="f1_macro")
        acc_scores = cross_val_score(pipeline, X, y, groups=groups, cv=gkf, scoring="accuracy")
        
        mean_f1 = float(f1_scores.mean())
        std_f1 = float(f1_scores.std())
        mean_acc = float(acc_scores.mean())

        comparison_records.append({
            "model_name": name,
            "macro_f1": round(mean_f1, 4),
            "macro_f1_std": round(std_f1, 4),
            "accuracy": round(mean_acc, 4),
            "pipeline": pipeline
        })
        print(f"[{name}] Macro F1: {mean_f1:.4f} (+/- {std_f1:.4f}) | Accuracy: {mean_acc:.4f}")

    # Select best performing model
    best_candidate = max(comparison_records, key=lambda x: x["macro_f1"])
    best_name = best_candidate["model_name"]
    best_f1 = best_candidate["macro_f1"]
    best_pipeline = best_candidate["pipeline"]

    print(f"\n>>> Selected Best Model: {best_name} (Macro F1: {best_f1:.4f}) <<<")

    # Fit best model on complete dataset
    best_pipeline.fit(X, y)

    # Save to Model Registry
    os.makedirs(model_registry_dir, exist_ok=True)
    registry_file = os.path.join(model_registry_dir, "smriti_adaptive_model.joblib")
    
    artifact = {
        "model": best_pipeline,
        "model_name": best_name,
        "version": "v1.1.0-empirical",
        "macro_f1": best_f1,
        "feature_names": FEATURE_COLS,
        "target_names": ["DECREASE (-1)", "MAINTAIN (0)", "INCREASE (+1)"],
        "num_training_samples": len(df),
        "num_subjects": len(np.unique(groups)),
        "comparison_results": [
            {k: v for k, v in r.items() if k != "pipeline"} for r in comparison_records
        ]
    }

    joblib.dump(artifact, registry_file)
    print(f"Model serialized and registered at: {registry_file}\n")
    return artifact

if __name__ == "__main__":
    train_and_evaluate_all_models()

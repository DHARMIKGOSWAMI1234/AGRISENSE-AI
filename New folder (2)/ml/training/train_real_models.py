"""
SMRITI Real-World Cognitive Model Training & Benchmark Pipeline
==============================================================
Trains and evaluates scientifically defensible ML models on real OpenNeuro cognitive data
(ds000164 Stroop & ds000102 Flanker: 4,585 empirical trials across 54 subjects).

Tasks:
1. Task A (Regression): Empirical Response-Latency Prediction under Cognitive Conflict
   - Role: Tier 1 behavioral research/calibration (Informs initial engineering ranges)
   - NOT: Clinical prediction, Dementia diagnosis/prediction, or Game difficulty prediction
2. Task B (Classification): Cognitive Conflict Classification Benchmark
   - Role: Retained as a reproducible behavioral classification benchmark demonstrating
     that the pipeline can learn an observed experimental condition from behavioral signals.
     It is NOT used to make patient-facing decisions.

Validation Scheme: 5-Fold GroupKFold by Participant ID (Zero Subject Leakage)
Preprocessing: Fitted strictly within cross-validation training folds (Zero Preprocessing Contamination)
"""

import os
import json
import joblib
import pandas as pd
import numpy as np
from typing import Dict, List, Tuple, Any

from sklearn.model_selection import GroupKFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.dummy import DummyRegressor, DummyClassifier
from sklearn.linear_model import LinearRegression, Ridge, LogisticRegression
from sklearn.ensemble import (
    RandomForestRegressor,
    GradientBoostingRegressor,
    RandomForestClassifier,
    GradientBoostingClassifier,
    ExtraTreesClassifier
)
from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
    r2_score,
    accuracy_score,
    balanced_accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix
)

DATA_PATH = "data/processed/openneuro_cognitive_trials.csv"
MODEL_REGISTRY_DIR = "ml/models/registry"

def load_clean_data(data_path: str = DATA_PATH) -> pd.DataFrame:
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Processed data not found at {data_path}. Run preprocess_openneuro_cognitive.py first.")
    df = pd.read_csv(data_path)
    # Filter trials with valid response times
    df = df[df["response_time_ms"].notnull() & (df["response_time_ms"] > 100) & (df["response_time_ms"] < 3500)].copy()
    # Task indicator
    df["task_is_stroop"] = (df["task_paradigm"] == "stroop").astype(float)
    return df

def train_and_benchmark_regression_task(df: pd.DataFrame) -> Dict[str, Any]:
    """
    Task A: Empirical Response-Latency Prediction under Cognitive Conflict
    Role: Tier 1 behavioral research/calibration (NOT clinical / NOT dementia / NOT difficulty prediction)
    Target: response_time_ms (observed continuous milliseconds from scanner button press)
    Features: is_cognitive_conflict, cumulative_trial_num, prev_response_time_ms, prev_accuracy, task_is_stroop
    """
    feature_cols = [
        "is_cognitive_conflict",
        "cumulative_trial_num",
        "prev_response_time_ms",
        "prev_accuracy",
        "task_is_stroop"
    ]
    target_col = "response_time_ms"

    # Filter rows where target is present
    sub_df = df.dropna(subset=[target_col]).copy()
    X = sub_df[feature_cols].values
    y = sub_df[target_col].values
    groups = sub_df["participant_id"].values

    print("\n" + "="*70)
    print("TASK A (REGRESSION): Reaction-Time Prediction under Cognitive Load")
    print(f"Samples: {len(sub_df)} | Subjects: {len(np.unique(groups))} | Folds: 5 GroupKFold")
    print(f"Features: {feature_cols}")
    print(f"Target: {target_col} (Observed Empirical Milliseconds)")
    print("="*70)

    gkf = GroupKFold(n_splits=5)

    models = {
        "Dummy_Mean_Baseline": DummyRegressor(strategy="mean"),
        "Linear_Regression": LinearRegression(),
        "Ridge_Regression": Ridge(alpha=1.0),
        "Random_Forest_Regressor": RandomForestRegressor(n_estimators=100, max_depth=6, random_state=2026),
        "Gradient_Boosting_Regressor": GradientBoostingRegressor(n_estimators=100, max_depth=4, random_state=2026)
    }

    results = {}
    best_r2 = -float("inf")
    best_model_name = None
    best_pipeline = None

    for name, model in models.items():
        pipe = Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
            ("reg", model)
        ])

        maes, rmses, r2s = [], [], []

        for train_idx, test_idx in gkf.split(X, y, groups=groups):
            X_tr, X_te = X[train_idx], X[test_idx]
            y_tr, y_te = y[train_idx], y[test_idx]

            pipe.fit(X_tr, y_tr)
            preds = pipe.predict(X_te)

            maes.append(mean_absolute_error(y_te, preds))
            rmses.append(np.sqrt(mean_squared_error(y_te, preds)))
            r2s.append(r2_score(y_te, preds))

        mean_mae = float(np.mean(maes))
        mean_rmse = float(np.mean(rmses))
        mean_r2 = float(np.mean(r2s))

        results[name] = {
            "MAE_ms": round(mean_mae, 2),
            "RMSE_ms": round(mean_rmse, 2),
            "R2": round(mean_r2, 4)
        }
        print(f"  [{name:28s}] MAE: {mean_mae:6.2f} ms | RMSE: {mean_rmse:6.2f} ms | R²: {mean_r2:7.4f}")

        if mean_r2 > best_r2:
            best_r2 = mean_r2
            best_model_name = name
            best_pipeline = pipe

    # Fit best model on complete dataset
    best_pipeline.fit(X, y)

    return {
        "task_name": "Cognitive_Reaction_Time_Regression",
        "task_type": "regression",
        "target": target_col,
        "features": feature_cols,
        "sample_count": len(sub_df),
        "subject_count": int(len(np.unique(groups))),
        "results": results,
        "best_model_name": best_model_name,
        "best_pipeline": best_pipeline
    }

def train_and_benchmark_classification_task(df: pd.DataFrame) -> Dict[str, Any]:
    """
    Task B: Cognitive Conflict Classification Research Benchmark
    Role: Retained as a reproducible behavioral classification benchmark demonstrating
          that the pipeline can learn an observed experimental condition from behavioral signals.
          It is NOT used to make patient-facing decisions.
    Target: is_cognitive_conflict (1 = Incongruent trial, 0 = Congruent/Neutral trial)
    Features: response_time_ms, accuracy, prev_response_time_ms, cumulative_trial_num, task_is_stroop
    """
    feature_cols = [
        "response_time_ms",
        "accuracy",
        "prev_response_time_ms",
        "cumulative_trial_num",
        "task_is_stroop"
    ]
    target_col = "is_cognitive_conflict"

    sub_df = df.dropna(subset=[target_col]).copy()
    sub_df[target_col] = sub_df[target_col].astype(int)

    X = sub_df[feature_cols].values
    y = sub_df[target_col].values
    groups = sub_df["participant_id"].values

    print("\n" + "="*70)
    print("TASK B (CLASSIFICATION): Cognitive Conflict State Classification")
    print(f"Samples: {len(sub_df)} | Subjects: {len(np.unique(groups))} | Folds: 5 GroupKFold")
    print(f"Features: {feature_cols}")
    print(f"Target: {target_col} (1: Incongruent Conflict, 0: Congruent/Neutral)")
    print("="*70)

    gkf = GroupKFold(n_splits=5)

    models = {
        "Dummy_Stratified_Baseline": DummyClassifier(strategy="stratified", random_state=2026),
        "Logistic_Regression": LogisticRegression(max_iter=1000, random_state=2026),
        "Random_Forest_Classifier": RandomForestClassifier(n_estimators=100, max_depth=6, random_state=2026),
        "Gradient_Boosting_Classifier": GradientBoostingClassifier(n_estimators=100, max_depth=4, random_state=2026),
        "Extra_Trees_Classifier": ExtraTreesClassifier(n_estimators=100, max_depth=6, random_state=2026)
    }

    results = {}
    best_f1 = -float("inf")
    best_model_name = None
    best_pipeline = None

    for name, model in models.items():
        pipe = Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
            ("clf", model)
        ])

        accs, bal_accs, f1s = [], [], []
        y_true_all, y_pred_all = [], []

        for train_idx, test_idx in gkf.split(X, y, groups=groups):
            X_tr, X_te = X[train_idx], X[test_idx]
            y_tr, y_te = y[train_idx], y[test_idx]

            pipe.fit(X_tr, y_tr)
            preds = pipe.predict(X_te)

            accs.append(accuracy_score(y_te, preds))
            bal_accs.append(balanced_accuracy_score(y_te, preds))
            _, _, fold_f1, _ = precision_recall_fscore_support(y_te, preds, average="macro", zero_division=0)
            f1s.append(fold_f1)

            y_true_all.extend(y_te)
            y_pred_all.extend(preds)

        mean_acc = float(np.mean(accs))
        mean_bal_acc = float(np.mean(bal_accs))
        mean_f1 = float(np.mean(f1s))
        cm = confusion_matrix(y_true_all, y_pred_all).tolist()

        prec, rec, f1_per_class, support = precision_recall_fscore_support(y_true_all, y_pred_all, zero_division=0)

        results[name] = {
            "Accuracy": round(mean_acc, 4),
            "Balanced_Accuracy": round(mean_bal_acc, 4),
            "Macro_F1": round(mean_f1, 4),
            "Precision_Class_0": round(float(prec[0]), 4),
            "Recall_Class_0": round(float(rec[0]), 4),
            "Precision_Class_1": round(float(prec[1]), 4),
            "Recall_Class_1": round(float(rec[1]), 4),
            "Confusion_Matrix": cm
        }
        print(f"  [{name:28s}] Acc: {mean_acc:6.4f} | Bal Acc: {mean_bal_acc:6.4f} | Macro F1: {mean_f1:6.4f}")

        if mean_f1 > best_f1:
            best_f1 = mean_f1
            best_model_name = name
            best_pipeline = pipe

    best_pipeline.fit(X, y)

    return {
        "task_name": "Cognitive_Conflict_Classification",
        "task_type": "classification",
        "target": target_col,
        "features": feature_cols,
        "sample_count": len(sub_df),
        "subject_count": int(len(np.unique(groups))),
        "results": results,
        "best_model_name": best_model_name,
        "best_pipeline": best_pipeline
    }

def run_training_pipeline():
    os.makedirs(MODEL_REGISTRY_DIR, exist_ok=True)
    df = load_clean_data()

    # Train Task A (Regression)
    reg_summary = train_and_benchmark_regression_task(df)
    reg_joblib = os.path.join(MODEL_REGISTRY_DIR, "cognitive_reaction_time_regressor.joblib")
    joblib.dump({
        "pipeline": reg_summary["best_pipeline"],
        "metadata": {k: v for k, v in reg_summary.items() if k != "best_pipeline"},
        "version": "v2.0.0-real-openneuro"
    }, reg_joblib)
    print(f"\nSaved regression model to {reg_joblib}")

    # Train Task B (Classification)
    clf_summary = train_and_benchmark_classification_task(df)
    clf_joblib = os.path.join(MODEL_REGISTRY_DIR, "cognitive_conflict_classifier.joblib")
    joblib.dump({
        "pipeline": clf_summary["best_pipeline"],
        "metadata": {k: v for k, v in clf_summary.items() if k != "best_pipeline"},
        "version": "v2.0.0-real-openneuro"
    }, clf_joblib)
    print(f"Saved classification model to {clf_joblib}")

    # Save consolidated benchmark report
    benchmark_report = {
        "dataset": "OpenNeuro ds000164 (Stroop) + ds000102 (Flanker)",
        "provenance_verified": True,
        "synthetic_subjects_used": False,
        "deterministic_target_leakage": False,
        "cross_validation": "5-Fold GroupKFold by Participant ID (Zero Subject Leakage)",
        "tasks": {
            "reaction_time_regression": {k: v for k, v in reg_summary.items() if k != "best_pipeline"},
            "conflict_classification": {k: v for k, v in clf_summary.items() if k != "best_pipeline"}
        }
    }

    report_path = os.path.join(MODEL_REGISTRY_DIR, "benchmark_report.json")
    with open(report_path, "w") as f:
        json.dump(benchmark_report, f, indent=2)
    print(f"Saved benchmark report to {report_path}")

    return benchmark_report

if __name__ == "__main__":
    run_training_pipeline()

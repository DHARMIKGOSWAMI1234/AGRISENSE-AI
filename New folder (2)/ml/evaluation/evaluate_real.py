import os
import joblib
import pandas as pd
from sklearn.metrics import classification_report, confusion_matrix
from ml.training.train_real import FEATURE_COLS

def run_empirical_evaluation(
    model_path: str = "ml/models/registry/smriti_adaptive_model.joblib",
    test_data_path: str = "ml/datasets/processed/cognitive_performance_trials.csv"
):
    if not os.path.exists(model_path):
        print(f"Model artifact not found at {model_path}. Run train_real.py first.")
        return

    artifact = joblib.load(model_path)
    model = artifact["model"]
    model_name = artifact["model_name"]
    target_names = artifact["target_names"]

    df = pd.read_csv(test_data_path)
    X = df[FEATURE_COLS]
    y_true = df["target_action"].values

    y_pred = model.predict(X)

    print("\n=======================================================")
    print(f"EVALUATION REPORT: {model_name} (Version: {artifact.get('version', 'v1.1.0')})")
    print(f"Training Dataset: {artifact.get('num_training_samples')} trials from {artifact.get('num_subjects')} participants")
    print(f"=======================================================")
    print(classification_report(y_true, y_pred, target_names=target_names, digits=4))
    
    print("Confusion Matrix:")
    cm = confusion_matrix(y_true, y_pred)
    print(cm)
    
    print("\nModel Comparison Summary (from GroupKFold CV):")
    for comp in artifact.get("comparison_results", []):
        print(f" - {comp['model_name']}: Macro F1 = {comp['macro_f1']} (std: {comp['macro_f1_std']}), Accuracy = {comp['accuracy']}")
    print("=======================================================\n")

if __name__ == "__main__":
    run_empirical_evaluation()

import os
import joblib
import pandas as pd
from sklearn.metrics import classification_report, confusion_matrix
from ml.feature_engineering.extract_features import extract_features_and_labels

def evaluate_registered_model(model_path: str = "ml/models/registry/smriti_adaptive_model.joblib", test_data_path: str = "ml/datasets/cleaned_interactions.csv"):
    if not os.path.exists(model_path):
        print(f"Model not found at {model_path}. Please run train.py first.")
        return

    artifact = joblib.load(model_path)
    model = artifact["model"]
    model_name = artifact.get("model_name", "Unknown")

    df = pd.read_csv(test_data_path)
    X, y, _ = extract_features_and_labels(df)

    y_pred = model.predict(X)

    target_names = ["DECREASE (-1)", "MAINTAIN (0)", "INCREASE (+1)"]
    print(f"\n=======================================================")
    print(f"EVALUATION REPORT FOR: {model_name} (Version: {artifact.get('version', 'v1.0.0')})")
    print(f"=======================================================")
    print(classification_report(y, y_pred, target_names=target_names))
    print("Confusion Matrix:")
    print(confusion_matrix(y, y_pred))

if __name__ == "__main__":
    evaluate_registered_model()

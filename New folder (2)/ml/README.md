# SMRITI Machine Learning Pipeline

## Overview
This directory contains the reproducible machine learning pipeline for SMRITI's **Cognitive Engagement & Adaptive Difficulty Recommendation Engine**.

### Architecture
- `datasets/`: Reproducible synthetic interaction data generator and verified open metadata.
- `preprocessing/`: Data validation, cleaning, and sanitization.
- `feature_engineering/`: Feature extraction with leakage-free patient grouping.
- `training/`: Supervised model training (Logistic Regression baseline, Random Forest, Gradient Boosting).
- `evaluation/`: Multi-class evaluation (Precision, Recall, Macro F1, Confusion Matrix).
- `models/registry/`: Exported serialized models, encoders, and version metadata.
- `inference/`: Low-latency standalone inference module.

### How to Run ML Pipeline
```bash
# 1. Generate synthetic interaction data
python -m preprocessing.prepare_data

# 2. Train baseline and candidate models
python -m training.train

# 3. Evaluate models on holdout patient groups
python -m evaluation.evaluate
```

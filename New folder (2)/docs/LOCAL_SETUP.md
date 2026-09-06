# SMRITI Local Development & Setup Guide

## System Requirements
- OS: Windows 10/11, macOS, or Linux
- Flutter SDK $\ge 3.24.0$ (with Dart $\ge 3.5.0$)
- Python $\ge 3.11$
- Node.js $\ge 20.0.0$ & npm $\ge 10.0.0$
- PostgreSQL 16 (or local SQLite fallback)

---

## 1. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Create and activate Python virtual environment
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
# source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy environment variables
cp .env.example .env

# Run FastAPI server
uvicorn app.main:app --reload --port 8000
# API docs available at http://localhost:8000/docs
```

---

## 2. Dashboard Setup (React / TypeScript / Vite)
```bash
# Navigate to dashboard directory
cd dashboard

# Install dependencies
npm install

# Run Vite development server
npm run dev
# Dashboard accessible at http://localhost:5173
```

---

## 3. Mobile App Setup (Flutter)
```bash
# Navigate to mobile directory
cd mobile

# Fetch Flutter dependencies
flutter pub get

# Run on connected device or Android emulator
flutter run
```

---

## 4. ML Pipeline Execution
```bash
# Navigate to ml directory
cd ml

# Generate synthetic dataset and train models
python -m preprocessing.prepare_data
python -m training.train
python -m evaluation.evaluate
```

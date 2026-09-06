# SMRITI Mobile Client (Flutter)

## Architecture Overview
The Flutter mobile application is designed specifically for elderly dementia patients with low digital literacy and rural connectivity:
- **Elderly-First UI:** Large high-contrast touch targets ($\ge 56\,\text{dp}$), bold text, calm pacing, zero punishment.
- **Offline-First:** Local SQLite database persistence for all game sessions and reminder completions.
- **Multilingual Support:** English, Hindi, and Assamese (অসমীয়া) with extensible NER language architecture.
- **Cognitive Games:** Memory Match, Pattern Recognition, Daily Routine Recall, Remember the Objects, Familiar Memory.
- **Adaptive Engine:** Tier 0 deterministic rules engine with explainable reason codes.

### Build & Run
```bash
flutter pub get
flutter test
flutter run
```

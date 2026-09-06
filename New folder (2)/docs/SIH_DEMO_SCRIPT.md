# SMRITI SIH 2026 Presentation & Live Demo Script (7-Minute Blueprint)

## 0:00 - 0:45: The Problem & The North Eastern Context
- **Speaker:** "Good morning, respected judges. In the North Eastern Region of India, elderly dementia patients and their family caregivers face a triple challenge: limited specialist access, low digital literacy, and frequent internet blackouts. Existing brain-training apps fail because they require constant high-speed connectivity, use abstract Western games, and treat dementia as a trivial high-score game."
- **Slide:** The Triple Burden in NER (Dementia + Low Connectivity + Cultural Disconnect).

## 0:45 - 2:00: The Patient App & Elderly-First UX
- **Action:** Open Flutter mobile application on tablet/phone.
- **Showcase:** Large high-contrast buttons, spoken Assamese/Hindi prompt ("Let's do one short memory activity today").
- **Gameplay:** Play *Memory Match* using localized Assamese artifacts (*Japi, Gamusa, Pitha*).
- **Result:** Display calm, encouraging summary: "You completed 4 of 4 pairs!" (Zero clinical dementia diagnostic labels).

## 2:00 - 3:00: Explainable Adaptive Intelligence
- **Action:** Inspect next round generation.
- **Showcase:** Show how consistent high accuracy ($\ge 85\%$) and comfortable response time gradually adapt the grid size with explicit reason code `HIGH_SUCCESS_RATE`.

## 3:00 - 4:00: Live Offline-First Proof (The Airplane Mode Test)
- **Action:** Switch mobile device to **Airplane Mode (No Internet)**.
- **Gameplay:** Play *Daily Routine Recall* (sequencing morning medication & tea).
- **Showcase:** Game completes and persists locally to SQLite instantly. Inspect local sync queue status: `PENDING`.
- **Kill App:** Hard-kill and reopen app; show that data and progress survived 100% intact offline.

## 4:00 - 5:00: Daily Routine & Medication Reminders
- **Action:** Trigger a caregiver-scheduled medication reminder.
- **Showcase:** Elderly-friendly `Done / Later / Skip` dialog with audio readout.

## 5:00 - 6:00: Reconnecting & Caregiver Sync
- **Action:** Turn Airplane Mode OFF (Internet Restored).
- **Showcase:** Background sync triggers immediately with idempotent batch upload.
- **Switch to Dashboard:** Open Caregiver React Dashboard. Point to real-time update of today's completed session and longitudinal 7-day adherence chart.

## 6:00 - 7:00: Technical Differentiation & Medical Safety Boundary
- **Summary:** "SMRITI is not an unverified AI diagnostic tool. It is an offline-first, culturally localized, adaptive cognitive companion that empowers elderly patients and gives caregivers actionable visibility."
- **Q&A Readiness:** Reference architecture, ACID SQLite local store, and leakage-free ML evaluation pipeline.

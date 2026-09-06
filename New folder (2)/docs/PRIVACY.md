# SMRITI Privacy & Consent Architecture

## 1. Data Minimization Principles
SMRITI strictly adheres to data minimization:
1. **Zero Continuous Microphone Recording:** Voice interaction is user-initiated only with clear visual listening indicators.
2. **Zero Camera Data Collection in MVP:** No facial emotion recognition or camera-based biometric tracking.
3. **No Unnecessary Location Tracking:** App operates without GPS or fine location permissions.
4. **Separation of Patient & Caregiver Identities:** Elderly patient UI operates with frictionless, low-pressure profile access; caregiver accounts hold credentials.

## 2. Consent Model
- **Caregiver Administrative Consent:** Required during patient registration to log cognitive engagement sessions.
- **Health Worker Consented Cohort Access:** Requires explicit patient/caregiver permission grant before summary trends can be viewed by community workers.
- **Research Data Isolation:** Research and training data are strictly synthetic or decoupled from live patient databases.

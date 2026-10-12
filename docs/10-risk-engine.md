# 10 – Risk Engine

## Scoring

Contributions are additive per distinct event type for a device (double-counting of identical repeated events is limited by context windows).

| Contribution              | Points |
|---------------------------|--------|
| Unknown Device            | +20    |
| Failed Authentication     | +15    |
| Message Flood             | +25    |
| Topic Abuse               | +25    |
| Abnormal Value            | +15    |
| Device Spoofing           | +30    |

## Bands

| Score   | Severity  |
|---------|-----------|
| 0–29    | LOW       |
| 30–59   | MEDIUM    |
| 60–79   | HIGH      |
| 80–100  | CRITICAL  |

Score is capped at 100.

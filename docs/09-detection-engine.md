# 09 – Detection Engine

## Event Types

| Event Type                  | Severity | Risk Contrib | Description |
|-----------------------------|----------|--------------|-------------|
| UNAUTHORIZED_DEVICE         | HIGH     | +20          | Unknown device_id |
| SENSOR_VALUE_ANOMALY        | MEDIUM   | +15          | Value outside project threshold |
| MESSAGE_RATE_ANOMALY        | HIGH     | +25          | Rate exceeds baseline × multiplier |
| TOPIC_ABUSE                 | HIGH     | +25          | Publish to forbidden topic |
| DEVICE_SPOOFING             | HIGH     | +30          | Duplicate identity observation |
| AUTHENTICATION_ANOMALY      | MEDIUM   | +15          | Repeated failed auth (controlled) |
| SCHEMA_VALIDATION_FAILURE   | MEDIUM   | +10          | Malformed message |
| CORRELATED_SECURITY_INCIDENT| CRITICAL | derived      | Multiple related events in window |

## Baselines (simulation parameters)

- TEMP-001: 20–35 °C, anomaly threshold 50 °C
- HUM-001: 40–70 %, anomaly threshold 95 %
- Rate: typically 1–5 msg/min; anomaly when ≫ baseline

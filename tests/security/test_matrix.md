# Security Test Matrix

| Test | Input | Expected Detection | Expected Response |
|------|-------|--------------------|-------------------|
| Normal telemetry | valid message | none | allow |
| Unknown device | TEMP-999 | UNAUTHORIZED_DEVICE | alert |
| Bad value | 150°C | SENSOR_VALUE_ANOMALY | alert |
| Flood | high rate | MESSAGE_RATE_ANOMALY | isolate if critical |
| Wrong credentials | invalid auth | AUTHENTICATION_ANOMALY | alert |
| Topic abuse | unauthorized topic | TOPIC_ABUSE | block |
| Spoofing | duplicate identity | DEVICE_SPOOFING / dual client | alert/isolate |
| Correlation | multiple events | CORRELATED_SECURITY_INCIDENT | contain |
| Isolated device | post-isolation telemetry | POST_ISOLATION_BLOCKED | reject |
| Recovery | admin recover | DEVICE_RECOVERED | ACTIVE |

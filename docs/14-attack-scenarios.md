# 14 – Attack Scenarios

All attacks target **only** the local project broker (host allow-list in `SafeMQTTClient`).

| ID | Scenario | Command | Detection | Notes |
|----|----------|---------|-----------|-------|
| TEST-001 | Normal telemetry | `python -m simulator.cli normal` | none | allow |
| TEST-002 | Unauthorized device | `python -m simulator.cli attack unauthorized-device` | UNAUTHORIZED_DEVICE | |
| TEST-003 | Abnormal value | `python -m simulator.cli attack abnormal-value --device TEMP-001` | SENSOR_VALUE_ANOMALY | |
| TEST-004 | MQTT flood | `python -m simulator.cli attack flood --device CAM-001` | MESSAGE_RATE_ANOMALY | |
| TEST-005 | Auth failure | `python -m simulator.cli attack auth-failure` | AUTHENTICATION_ANOMALY | **Stage B only** — Stage A prints SKIPPED |
| TEST-006 | Topic abuse | `python -m simulator.cli attack topic-abuse --device TEMP-001` | TOPIC_ABUSE | ACL also blocks in Stage B |
| TEST-007 | Spoofing | `python -m simulator.cli attack spoofing --device TEMP-001` | DEVICE_SPOOFING | uses `client_instance` spoof-A / spoof-B |
| TEST-008 | Correlation | multiple events in window | CORRELATED_SECURITY_INCIDENT | |
| TEST-009 | Critical risk | escalate via flood + others | risk ≥ 80 | |
| TEST-010 | Logical isolation | automatic at CRITICAL | status ISOLATED | |
| TEST-011 | Post-isolation | telemetry after isolate | POST_ISOLATION_BLOCKED | |

## Limitations

- Spoofing detection assumes distinct `client_instance` values; it is not cryptographic identity.
- Auth-failure detection requires Mosquitto Stage B (`allow_anonymous false`).

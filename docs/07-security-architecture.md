# 07 – Security Architecture

## Layers

1. **Transport** – TLS on port 8883 (final configuration)
2. **Authentication** – Mosquitto password file (per-device credentials)
3. **Authorization** – ACL least privilege (topic scope per device)
4. **Application Validation** – Node-RED schema, identity, topic, rate, value checks
5. **Risk & Response** – Deterministic scoring + logical isolation

## Terminology

- Authentication = Who are you?
- Authorization = What are you allowed to do?
- TLS = How is communication protected in transit?

## Logical Isolation

Device states: `ACTIVE` | `SUSPICIOUS` | `ISOLATED`

When `ISOLATED`, subsequent telemetry from that device is rejected by the pipeline and recorded.

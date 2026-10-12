# 03 – Requirements

## Functional requirements

| ID | Requirement |
|----|-------------|
| FR-01 | Simulate six IoT devices publishing structured JSON telemetry over MQTT |
| FR-02 | Validate required fields: device_id, device_type, timestamp, sequence, value, unit |
| FR-03 | Detect unknown device identity (UNAUTHORIZED_DEVICE) |
| FR-04 | Detect abnormal sensor values against project thresholds |
| FR-05 | Detect message-rate anomalies using a sliding window |
| FR-06 | Detect topic abuse and device spoofing (client_instance) |
| FR-07 | Correlate multiple event types within a time window |
| FR-08 | Compute deterministic risk scores and severity bands |
| FR-09 | Perform logical isolation and audited recovery |
| FR-10 | Persist evidence (JSONL and/or SQLite schema) |
| FR-11 | Present SOC-oriented dashboard panels |
| FR-12 | Provide Stage A (anonymous) and Stage B (auth/ACL/TLS) MQTT modes |

## Non-functional requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Reproducible from clean checkout on Windows + Docker Desktop |
| NFR-02 | No cloud account required for core operation |
| NFR-03 | Secrets never committed to version control |
| NFR-04 | Attack simulator restricted to local broker hosts |
| NFR-05 | Tests must not print PASS without executing real checks |

## Pinned / target versions

| Component | Version |
|-----------|---------|
| Docker Engine | 24+ |
| Docker Compose | v2 (or 1.29+) |
| eclipse-mosquitto | 2.0.18 |
| nodered/node-red | 3.1.9 |
| node-red-dashboard | 3.6.5 |
| node-red-node-sqlite | 1.0.2 (optional wiring) |
| Python | 3.10+ |
| paho-mqtt | 2.1.0 |
| pytest | 8.3.3 |
| Windows | 10/11 + PowerShell 5.1+ |

These versions are recorded so that academic reproduction does not depend on floating “latest” tags without documentation.

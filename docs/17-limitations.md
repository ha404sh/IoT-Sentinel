# 17 – Limitations

- Simulated environment only; no physical IoT hardware.
- Detection is rule-based + behavioral baselines (not ML).
- Isolation is logical (application state), not network-level.
- TLS and full ACL enforcement require certificate generation and password file population on the host.
- Docker-in-Docker is not available in every sandbox; full runtime tests require Windows + Docker Desktop.
- Correlation window and rate windows are bounded in-memory; restart loses ephemeral state (persisted events remain in SQLite when configured).
- Spoofing detection relies on observed concurrent clients / sequence anomalies and has inherent limitations without strong device credentials bound to client certificates.

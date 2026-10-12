# 08 – Device Profiling

## Purpose

Behavioral profiling establishes what “normal” looks like for each logical device so that deviations can be scored without machine learning.

## Rate baseline

- Sliding window: 60 seconds of message timestamps per `device_id`.
- Normal operation: approximately 1–5 messages per minute (up to 10 for motion).
- Anomaly threshold: more than 30 messages in the window (documented multiplier over baseline).
- Memory is bounded: old timestamps are pruned; arrays are capped.

## Value baseline

- TEMP-001 and HUM-001 compare numeric `value` against project anomaly thresholds (50 °C and 95 %).
- Enum/boolean devices rely on schema validity rather than numeric ranges.

## Client instance tracking

Each message carries `client_instance`. Normal traffic uses `default`. The spoofing attack publishes alternating `spoof-A` and `spoof-B`. If the stored instance for a device changes, DEVICE_SPOOFING is raised.

This is a **lab heuristic**, not cryptographic identity. Mutual TLS client certificates would be a future hardening step.

## Registry state

The logical registry tracks `ACTIVE`, `SUSPICIOUS`, and `ISOLATED`. Isolation is applied by the response engine at CRITICAL risk and enforced by the isolation gate before identity/rate checks on subsequent messages.

## How baselines are established

Baselines are configuration-driven (environment thresholds and constants in Node-RED function nodes), not learned from long historical training sets. The first messages of a run populate rate windows; thresholds are fixed for reproducibility of acceptance tests.


## Interaction with isolation

Profiling still runs only for non-isolated devices. Once ISOLATED, the isolation gate short-circuits processing and emits POST_ISOLATION_BLOCKED instead of updating rate windows for accepted telemetry.

## Configuration sources

Thresholds may be adjusted via `.env` (TEMP_ANOMALY_THRESHOLD, HUM_ANOMALY_THRESHOLD, RATE_ANOMALY_MULTIPLIER) and corresponding Node-RED constants. Changes should be documented when used for grading.

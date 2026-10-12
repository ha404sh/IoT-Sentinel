# 05 – IoT Design

## Simulation parameters (not universal physical limits)

The ranges below are chosen for laboratory demonstration. They are **not** claimed as industry safety limits for real sensors.

| Device ID | Type | Unit | Normal range / values | Normal rate | Anomaly threshold | Allowed publish topic |
|-----------|------|------|----------------------|-------------|-------------------|------------------------|
| TEMP-001 | temperature | C | 20–35 | 1–5 msg/min | value > 50 | iot/telemetry/temperature/TEMP-001 |
| HUM-001 | humidity | % | 40–70 | 1–5 msg/min | value > 95 | iot/telemetry/humidity/HUM-001 |
| MOTION-001 | motion | — | true / false | 1–10 msg/min | — | iot/telemetry/motion/MOTION-001 |
| DOOR-001 | door | — | open / closed | 1–5 msg/min | — | iot/telemetry/door/DOOR-001 |
| CAM-001 | camera | — | online / offline | 1–5 msg/min | — | iot/telemetry/camera/CAM-001 |
| LIGHT-001 | light | — | on / off | 1–5 msg/min | — | iot/telemetry/light/LIGHT-001 |

## Telemetry schema

Every normal message includes:

- `device_id`, `device_type`, `value`, `unit`
- `timestamp` (UTC ISO-8601 ending with `Z`)
- `sequence` (non-negative integer)
- `client_instance` (default `default`; used for spoofing demos)

## Command topics

Actuator-style devices may receive commands under `iot/command/<DEVICE-ID>`. Devices must not publish to `iot/security/#` or administrative topics; such attempts generate TOPIC_ABUSE at the application layer and are denied by ACL in Stage B.

## Design rationale

Six device types cover continuous numeric sensors, boolean events, and enum state devices. This diversity exercises schema validation and value checks without requiring physical hardware.


## Identity model

Logical device IDs (TEMP-001 … LIGHT-001) map to MQTT usernames (temp01 … light01) in Stage B. Stage A does not enforce usernames, which is intentional for bootstrap.

## Timing and clocks

All timestamps are UTC ISO-8601 with a trailing Z. Mixed local time zones are avoided to keep correlation windows deterministic across hosts.

## Extensibility

Additional device types can be added by extending `simulator/config.py` DEVICES map, ACL entries, seed SQL, and Node-RED known-device lists. The pipeline assumes the same JSON schema.

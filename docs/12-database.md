# 12 – Database

## SQLite schema

Applied by `scripts/init-db.ps1` from `database/schema.sql` and `database/seed.sql`.

| Table | Key columns | Indexes |
|-------|-------------|---------|
| devices | device_id PK, device_type, status, risk_score, first_seen, last_seen | PK |
| telemetry | id PK, device_id, timestamp, value, unit, sequence | (device_id, timestamp) |
| security_events | event_id PK, device_id, event_type, severity, risk_score, timestamp, description, source, status, correlation_id, mqtt_topic, observed_value, expected_value, action | device/ts, type, severity |
| incidents | incident_id PK, device_id, attack_type, risk_score, action, status, created_at, resolved_at, related_event_ids, correlation_id | status, device |

Foreign keys reference `devices.device_id` where appropriate. Secrets are never stored in SQLite.

## Runtime evidence paths

| Path | Writer | Purpose |
|------|--------|---------|
| `database/iot_sentinel.db` | init-db + optional sqlite nodes | Structured queries |
| `database/events.jsonl` | Node-RED `fn_persist_event` | Append-only security events |
| `database/telemetry.jsonl` | Node-RED `fn_persist_tel` | Append-only valid telemetry |

JSONL files are mounted via `./database:/data/database` and are the primary source for `scripts/test.ps1` attack assertions because they are written by the live pipeline without requiring the optional sqlite palette package.

## Optional SQL nodes

Install `node-red-node-sqlite` and wire INSERT/UPSERT statements documented in earlier revisions of this file if durable SQL rows are required for grading. Until then, JSONL + seed SQLite remain the supported evidence path.

## Retention

In-memory Node-RED context windows are bounded. JSONL is append-only for the lab session; operators may truncate between runs. Unlimited growth is avoided in rate maps and recent-event buffers.


## Integrity practices

- Primary keys on event_id and incident_id
- Indexes on frequently filtered columns (severity, event_type, status)
- Avoid duplicate processing by using unique event IDs generated in the detection tab

## Operator maintenance

Between demos, stop the stack, remove `database/*.jsonl` and optionally re-run `init-db.ps1`, then start again for a clean evidence set.

-- IoT Sentinel SQLite Schema
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS devices (
    device_id     TEXT PRIMARY KEY,
    device_type   TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','SUSPICIOUS','ISOLATED')),
    risk_score    INTEGER NOT NULL DEFAULT 0 CHECK(risk_score >= 0 AND risk_score <= 100),
    first_seen    TEXT,
    last_seen     TEXT,
    allowed_topics TEXT,
    normal_message_rate TEXT,
    expected_value_range TEXT
);

CREATE TABLE IF NOT EXISTS telemetry (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id   TEXT NOT NULL,
    timestamp   TEXT NOT NULL,
    value       TEXT,
    unit        TEXT,
    sequence    INTEGER,
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

CREATE INDEX IF NOT EXISTS idx_telemetry_device_ts ON telemetry(device_id, timestamp);

CREATE TABLE IF NOT EXISTS security_events (
    event_id      TEXT PRIMARY KEY,
    device_id     TEXT,
    event_type    TEXT NOT NULL,
    severity      TEXT NOT NULL CHECK(severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    risk_score    INTEGER NOT NULL DEFAULT 0,
    timestamp     TEXT NOT NULL,
    description   TEXT,
    source        TEXT DEFAULT 'node-red-detection-engine',
    status        TEXT DEFAULT 'OPEN',
    correlation_id TEXT,
    mqtt_topic    TEXT,
    observed_value TEXT,
    expected_value TEXT,
    action        TEXT
);

CREATE INDEX IF NOT EXISTS idx_events_device_ts ON security_events(device_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_events_type ON security_events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_severity ON security_events(severity);

CREATE TABLE IF NOT EXISTS incidents (
    incident_id   TEXT PRIMARY KEY,
    device_id     TEXT,
    attack_type   TEXT NOT NULL,
    risk_score    INTEGER NOT NULL,
    action        TEXT,
    status        TEXT NOT NULL DEFAULT 'OPEN'
                  CHECK(status IN ('OPEN','INVESTIGATING','CONTAINED','RESOLVED')),
    created_at    TEXT NOT NULL,
    resolved_at   TEXT,
    related_event_ids TEXT,
    correlation_id TEXT
);

CREATE INDEX IF NOT EXISTS idx_incidents_status ON incidents(status);
CREATE INDEX IF NOT EXISTS idx_incidents_device ON incidents(device_id);

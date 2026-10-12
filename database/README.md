# Database

SQLite is used for persistence of devices, telemetry, security events and incidents.

## Files
- `schema.sql` – table definitions and indexes
- `seed.sql` – initial device registry

## Location
Default path: `./database/iot_sentinel.db` (configurable via `DB_PATH`).

Do not store secrets in the database.

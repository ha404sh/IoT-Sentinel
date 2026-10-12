# Node-RED Security Pipeline

Flows live in **`nodered/data/flows.json`** (mounted as `/data` in the container).

Tabs: 01-MQTT-INGEST → 02-VALIDATION → 03-DEVICE-REGISTRY → 04-BEHAVIOR (rate, spoofing, value) → 05-DETECTION → 06-CORRELATION → 07-RISK-ENGINE → 08-RESPONSE → 09-DATABASE → 10-DASHBOARD → 11-ADMIN

## Palette packages

Declared in `package.json`. On first start, install via Palette Manager if not auto-loaded:

- node-red-dashboard
- node-red-node-sqlite (optional for full SQL; JSONL persistence works without it)

## SQLite

See `docs/12-database.md`. JSONL files under `/data/database/*.jsonl` provide durable evidence out of the box.

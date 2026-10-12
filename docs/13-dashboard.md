# 13 – Dashboard

## Location

- Editor: http://localhost:1880
- UI: http://localhost:1880/ui
- Theme: dark SOC-oriented (Node-RED dashboard dark theme)

## Panels

| Panel | Group | Data source | Refresh | Purpose |
|-------|-------|-------------|---------|---------|
| SOC Stats | Device Status | `msg.stats` from `fn_dash_update` | 5 s | Totals: devices, active, suspicious, isolated, events, critical, open incidents |
| Device Registry | Device Registry | `msg.devices` | 5 s | Per-device type, status, risk, last seen |
| Threat Types | Threat Feed | `msg.threatTypes` | 5 s | Counts by event_type |
| Recent Threats table | Threat Feed | `msg.events` / ui_table | 5 s | Chronological threat feed |
| Risk Distribution | Risk Distribution | `msg.riskBuckets` | 5 s | LOW/MEDIUM/HIGH/CRITICAL counts |
| Incidents | Incidents | `msg.incidents` | 5 s | Incident id, device, attack, risk, status, action |

## Severity colors

- LOW — green
- MEDIUM — yellow
- HIGH — orange
- CRITICAL / ISOLATED — red

## SOC workflow mapping

1. Operator opens UI after normal traffic → expects six active devices and empty critical counts.
2. After an attack → Threat Types and Recent Threats update from real events.
3. After critical risk → Device Registry shows ISOLATED; Incidents panel lists containment.

Numbers must reflect pipeline state (global context and/or JSONL-backed events), not hard-coded constants.


## Limitations of the UI

The dashboard reflects Node-RED global context populated by the live pipeline. After a container restart without durable SQL wiring, historical panels start empty until new traffic arrives. JSONL files on disk retain session evidence for offline review.

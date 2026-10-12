# 15 – Testing

## Tier 1 — Unit (offline)

```powershell
pip install -r simulator/requirements.txt
python -m pytest tests/unit -v
```

Covers: telemetry model validation, six-device registry, topic formats, MQTT host allow-list, temperature ranges, sequence increments, risk score cap.

## Tier 2 — Integration

```powershell
python -m pytest tests/integration -v
```

Publishes a valid message when localhost:1883 is reachable; skips with reason if the broker is down.

## Tier 3 — Security harness

```powershell
python -m pytest tests/security -v
```

Runs attack helpers against a live broker; verifies Stage A auth-failure prints SKIPPED.

## Tier 4 — Acceptance (`scripts/test.ps1`)

Requires Docker Desktop:

```powershell
.\scripts\setup.ps1
.\scripts\start.ps1
Start-Sleep -Seconds 20
.\scripts\healthcheck.ps1
.\scripts\test.ps1
```

Assertions read **actual** `database/telemetry.jsonl` and `database/events.jsonl` counts for event types. Soft `Assert ($true)` is forbidden. If Docker is missing, the script exits **2** (partial), not 0.

## Mapping to TEST-001 … TEST-011

See `docs/14-attack-scenarios.md` and `tests/security/test_matrix.md`. TEST-005 remains Stage B only.

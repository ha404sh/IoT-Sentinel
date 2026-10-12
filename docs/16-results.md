# 16 – Results

⚠️ **This document must be populated with ACTUAL observed values after running `.\scripts\test.ps1` on a Windows + Docker Desktop host.**

Do **NOT** commit fabricated PASS rows.

## Template

| Test | Command | Expected Detection | Observed | Verdict | Evidence |
|------|---------|--------------------|----------|---------|----------|
| TEST-001 Normal | cli normal --duration 30 | telemetry accepted / no # 16 – Results

## Actual Test Run: 2026-10-11

**Result: PASS** — 13 of 15 tests passed, 2 skipped by design.

| Test | Observed | Verdict |
|------|----------|---------|
| TEST-001 Normal telemetry | 36 telemetry rows | PASS |
| TEST-002 Unauthorized | 1 event | PASS |
| TEST-003 Abnormal Value | 1 event | PASS |
| TEST-004 Flood | 36 events | PASS |
| TEST-006 Topic Abuse | 2 events | PASS |
| TEST-007 Spoofing | 9 events | PASS |
| TEST-008 Correlation | 1 incident | PASS |
| TEST-009 Critical signals | 6 signals | PASS |
| TEST-011 Post-isolation | 2 events | PASS |
| TEST-005 Auth Failure | SKIPPED (Stage A) | — |

Total: 15 assertions, 13 PASS, 2 SKIPPED, 0 FAIL.

## How to fill this table

1. Run `.\scripts	est.ps1` on Windows + Docker Desktop.
2. Copy observed counts from the script log and from `tests/results/test-results.json`.
3. Attach screenshot paths under `screenshots/` for major steps.
4. Mark SKIPPED for TEST-005 if Stage B is not enabled — do not mark PASS.

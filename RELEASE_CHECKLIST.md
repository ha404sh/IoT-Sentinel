# RELEASE CHECKLIST

| Item | Status | Evidence / note |
|------|--------|-----------------|
| broker/config/aclfile (file) | ✅ | Present as regular file |
| .env.example | ✅ | Present |
| .gitignore | ✅ | Present |
| LICENSE | ✅ | MIT 2026 |
| Makefile | ✅ | Present |
| screenshots/README.md | ✅ | Capture guide only |
| test.ps1 uses JSONL | ✅ | events.jsonl / telemetry.jsonl |
| No Assert($true) soft pass | ✅ | Removed |
| TEST-008 / TEST-011 in test.ps1 | ✅ | Present |
| Dashboard extra panels | ✅ | devices, threats, risk, incidents templates |
| docs 02,03,05,06,08,12,13,15,16 | ✅ | Real content |
| docs/16-results.md fabricated? | ✅ No | Template only |
| Unit tests | ✅ | 10 passed in sandbox |
| Full Docker acceptance TEST-001..011 | ⚠️ UNVERIFIED | Requires Windows + Docker Desktop operator run |
| Stage B TLS handshake | ⚠️ UNVERIFIED | generate-certs + secure conf on host |
| ACL is file inside container | ⚠️ UNVERIFIED until docker exec on host |

**Do not mark full acceptance PASS without pasting real `test.ps1` output from a Docker Desktop host.**

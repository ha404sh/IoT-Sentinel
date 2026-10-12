# Screenshots Evidence

Every screenshot must prove a specific behavior. Do not take random shots.

| Folder | Required Screenshot | When to Capture |
|--------|---------------------|-----------------|
| 01-environment | `docker ps` showing both containers healthy | After start.ps1 |
| 02-mqtt | `mosquitto_sub -t '#'` receiving telemetry | With simulator running |
| 03-simulator | Terminal showing `python -m simulator.cli normal` | During normal traffic |
| 04-normal | Dashboard showing 6 active devices, 0 critical events | 60s after normal traffic |
| 05-detection | Node-RED debug panel with an event | After an attack |
| 06-attacks | Terminal showing attack command + response | During attack |
| 07-response | Dashboard showing device ISOLATED | After critical risk |
| 08-security | Stage B: TLS handshake + ACL denial | After certs generated |
| 09-final | Full dashboard with all panels populated | End of demo |

Do **not** fabricate images. Capture only from a real local run.

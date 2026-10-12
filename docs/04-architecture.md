# 04 – Architecture

## System Architecture

```mermaid
flowchart TD
    A[IoT Simulator<br/>TEMP/HUM/MOTION/DOOR/CAM/LIGHT] -->|MQTT| B[Mosquitto Broker<br/>Auth / ACL / TLS]
    B --> C[Node-RED]
    C --> D[Validation]
    D --> E[Device Registry]
    E --> F[Behavior Profiling]
    F --> G[Detection Engine]
    G --> H[Event Correlation]
    H --> I[Risk Engine]
    I --> J[Response Engine]
    J --> K[SQLite]
    J --> L[Security Dashboard]
```

## Network

- Dedicated Docker bridge: `iot-sentinel-network`
- Exposed ports (documented):
  - 1883 – MQTT (development / non-TLS)
  - 8883 – MQTT over TLS
  - 1880 – Node-RED UI / Dashboard

## Security Pipeline (logical)

MQTT IN → JSON Decode → Schema Validation → Topic Validation → Device Identity → State Check → Behavior Analysis → Threat Detection → Correlation → Risk Scoring → Response → Database → Dashboard

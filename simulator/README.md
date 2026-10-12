# IoT Simulator

Python-based simulator for normal telemetry and controlled local attack scenarios.

## Install

```bash
pip install -r requirements.txt
```

## Normal traffic

```bash
python -m simulator.cli normal --duration 300 --interval 5
```

## Attacks (local broker only)

```bash
python -m simulator.cli attack flood --device CAM-001
python -m simulator.cli attack abnormal-value --device TEMP-001 --value 150
python -m simulator.cli attack unauthorized-device
python -m simulator.cli attack topic-abuse --device TEMP-001
python -m simulator.cli attack spoofing --device TEMP-001
python -m simulator.cli attack auth-failure
```

Safety: the client refuses connections to non-local hosts.

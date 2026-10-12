"""End-to-end integration tests.

These tests require a running Mosquitto on localhost:1883.
They are skipped automatically when the broker is unreachable.
"""
from __future__ import annotations

import json
import socket
import time
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]


def mqtt_reachable(host: str = "127.0.0.1", port: int = 1883, timeout: float = 1.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


pytestmark = pytest.mark.skipif(
    not mqtt_reachable(),
    reason="MQTT broker not reachable on localhost:1883 (start Docker stack first)",
)


def test_publish_valid_telemetry():
    """Publish one valid message; broker must accept without exception."""
    import sys
    sys.path.insert(0, str(ROOT))
    from simulator.config import MQTTConfig
    from simulator.devices import DeviceSimulator
    from simulator.mqtt_client import SafeMQTTClient

    sim = DeviceSimulator("TEMP-001")
    msg = sim.build_telemetry()
    client = SafeMQTTClient(MQTTConfig(), client_id="itest-temp")
    try:
        client.connect()
        client.publish(sim.topic(), msg.to_dict())
        time.sleep(0.5)
    finally:
        client.disconnect()
    assert msg.validate() == []


def test_jsonl_or_db_artifact_dir_exists():
    """database/ directory must exist for persistence mounts."""
    assert (ROOT / "database").is_dir()

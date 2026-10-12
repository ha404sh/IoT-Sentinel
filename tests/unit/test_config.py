"""Unit tests for device registry config."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from simulator.config import DEVICES, MQTTConfig


def test_six_devices():
    assert len(DEVICES) == 6
    for did in ["TEMP-001", "HUM-001", "MOTION-001", "DOOR-001", "CAM-001", "LIGHT-001"]:
        assert did in DEVICES


def test_topics_format():
    for d in DEVICES.values():
        assert d.topic.startswith("iot/telemetry/")
        assert d.device_id in d.topic


def test_mqtt_safety_hosts():
    cfg = MQTTConfig()
    assert "localhost" in cfg.allowed_hosts
    assert "127.0.0.1" in cfg.allowed_hosts

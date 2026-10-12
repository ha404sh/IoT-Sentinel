"""Security attack scenario tests (require running broker)."""
from __future__ import annotations

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
    reason="MQTT broker not reachable (start Docker stack first)",
)


def test_unauthorized_device_publishes():
    import sys
    sys.path.insert(0, str(ROOT))
    from simulator.attack_simulator import attack_unauthorized_device

    attack_unauthorized_device("TEMP-999")
    # Detection is performed by Node-RED; this test verifies the attack harness runs.
    time.sleep(1)


def test_abnormal_value_publishes():
    import sys
    sys.path.insert(0, str(ROOT))
    from simulator.attack_simulator import attack_abnormal_value

    attack_abnormal_value("TEMP-001", value=150.0)
    time.sleep(1)


def test_auth_failure_skips_on_stage_a(capsys):
    import sys
    sys.path.insert(0, str(ROOT))
    from simulator.attack_simulator import attack_auth_failure
    from simulator.config import MQTTConfig

    if MQTTConfig().allow_anonymous:
        attack_auth_failure()
        out = capsys.readouterr().out
        assert "SKIPPED" in out
    else:
        attack_auth_failure()

"""Controlled local-only attack simulations against the project broker."""
from __future__ import annotations

import logging
import time
from typing import Optional

from .config import DEVICES, MQTTConfig, TEMP_ANOMALY_THRESHOLD
from .devices import DeviceSimulator
from .mqtt_client import SafeMQTTClient
from .models import TelemetryMessage, utc_now_iso

logger = logging.getLogger("iot-sentinel.attack")

# Strict local rate limit for auth-failure attacks
AUTH_FAILURE_MAX = 5
AUTH_FAILURE_INTERVAL = 2.0


def attack_flood(device_id: str = "CAM-001", count: int = 200, interval: float = 0.05) -> None:
    """TEST-004: high message rate anomaly."""
    if device_id not in DEVICES:
        raise ValueError(f"Unknown device: {device_id}")
    config = MQTTConfig()
    client = SafeMQTTClient(config, client_id=f"flood-{device_id}")
    sim = DeviceSimulator(device_id)
    try:
        client.connect()
        logger.warning("Starting FLOOD attack on %s (%d messages)", device_id, count)
        for i in range(count):
            msg = sim.build_telemetry()
            client.publish(sim.topic(), msg.to_dict())
            time.sleep(interval)
        logger.warning("Flood complete")
    finally:
        client.disconnect()


def attack_abnormal_value(device_id: str = "TEMP-001", value: float = 150.0) -> None:
    """TEST-003: sensor value anomaly."""
    if device_id not in DEVICES:
        raise ValueError(f"Unknown device: {device_id}")
    config = MQTTConfig()
    client = SafeMQTTClient(config, client_id=f"abn-{device_id}")
    sim = DeviceSimulator(device_id)
    try:
        client.connect()
        msg = sim.build_telemetry(value=value)
        client.publish(sim.topic(), msg.to_dict())
        logger.warning("Abnormal value published: %s = %s", device_id, value)
    finally:
        client.disconnect()


def attack_unauthorized_device(fake_id: str = "TEMP-999") -> None:
    """TEST-002: unknown device identity."""
    config = MQTTConfig()
    client = SafeMQTTClient(config, client_id=f"unauth-{fake_id}")
    try:
        client.connect()
        msg = TelemetryMessage(
            device_id=fake_id,
            device_type="temperature",
            value=25.0,
            unit="C",
            timestamp=utc_now_iso(),
            sequence=1,
        )
        topic = f"iot/telemetry/temperature/{fake_id}"
        client.publish(topic, msg.to_dict())
        logger.warning("Unauthorized device message sent: %s", fake_id)
    finally:
        client.disconnect()


def attack_topic_abuse(device_id: str = "TEMP-001") -> None:
    """TEST-006: publish to unauthorized topic."""
    if device_id not in DEVICES:
        raise ValueError(f"Unknown device: {device_id}")
    config = MQTTConfig()
    client = SafeMQTTClient(config, client_id=f"abuse-{device_id}")
    try:
        client.connect()
        # Attempt to write to admin / security topics
        payload = {"device_id": device_id, "cmd": "reset", "timestamp": utc_now_iso()}
        client.publish("iot/admin/system/reset", payload)
        client.publish("iot/security/events", payload)
        logger.warning("Topic abuse attempted by %s", device_id)
    finally:
        client.disconnect()


def attack_spoofing(device_id: str = "TEMP-001") -> None:
    """TEST-007: two clients claim same identity."""
    if device_id not in DEVICES:
        raise ValueError(f"Unknown device: {device_id}")
    config = MQTTConfig()
    c1 = SafeMQTTClient(config, client_id=f"spoof-a-{device_id}")
    c2 = SafeMQTTClient(config, client_id=f"spoof-b-{device_id}")
    sim = DeviceSimulator(device_id)
    try:
        c1.connect()
        c2.connect()
        for i in range(5):
            msg1 = sim.build_telemetry(client_instance="spoof-A")
            msg2 = sim.build_telemetry(client_instance="spoof-B")
            c1.publish(sim.topic(), msg1.to_dict())
            c2.publish(sim.topic(), msg2.to_dict())
            time.sleep(0.5)
        logger.warning("Spoofing simulation complete for %s", device_id)
    finally:
        c1.disconnect()
        c2.disconnect()


def attack_auth_failure(device_id: str = "TEMP-001") -> None:
    """TEST-005: controlled failed authentication (local only, rate limited).
    Requires Stage B (MQTT_ALLOW_ANONYMOUS=false). In Stage A Mosquitto accepts
    anonymous connections so no AUTHENTICATION_ANOMALY is produced.
    """
    config = MQTTConfig()
    if config.allow_anonymous:
        logger.warning(
            "attack_auth_failure requires Stage B (MQTT_ALLOW_ANONYMOUS=false). "
            "Current config is Stage A — no detection will fire. See docs/14."
        )
        print("SKIPPED: Stage A does not enforce authentication.")
        return
    # Force non-anonymous attempt with wrong credentials
    for i in range(AUTH_FAILURE_MAX):
        client = SafeMQTTClient(config, client_id=f"authfail-{i}")
        try:
            client.connect(username="invalid_user", password="wrong_password")
        except Exception as exc:
            logger.warning("Auth failure attempt %d: %s", i + 1, exc)
        finally:
            try:
                client.disconnect()
            except Exception:
                pass
        time.sleep(AUTH_FAILURE_INTERVAL)
    logger.warning("Auth-failure simulation finished (max %d attempts)", AUTH_FAILURE_MAX)

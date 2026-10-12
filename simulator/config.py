"""Central configuration for the IoT Sentinel simulator."""
from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Tuple

from dotenv import load_dotenv

# Load .env from project root if present
ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")


@dataclass(frozen=True)
class MQTTConfig:
    host: str = os.getenv("MQTT_HOST", "localhost")
    port: int = int(os.getenv("MQTT_PORT", "1883"))
    tls_port: int = int(os.getenv("MQTT_TLS_PORT", "8883"))
    use_tls: bool = os.getenv("MQTT_USE_TLS", "false").lower() == "true"
    allow_anonymous: bool = os.getenv("MQTT_ALLOW_ANONYMOUS", "true").lower() == "true"
    username: str = os.getenv("MQTT_USERNAME", "")
    password: str = os.getenv("MQTT_PASSWORD", "")
    keepalive: int = 60
    # Safety: only allow connecting to local broker
    allowed_hosts: Tuple[str, ...] = ("localhost", "127.0.0.1", "mosquitto", "iot-sentinel-mosquitto")


@dataclass(frozen=True)
class DeviceSpec:
    device_id: str
    device_type: str
    topic: str
    username: str
    normal_rate_per_min: Tuple[int, int]  # (min, max)
    value_range: Tuple[float, float] | None
    unit: str
    value_type: str  # "float" | "bool" | "enum"
    enum_values: Tuple[str, ...] = ()


DEVICES: Dict[str, DeviceSpec] = {
    "TEMP-001": DeviceSpec(
        device_id="TEMP-001",
        device_type="temperature",
        topic="iot/telemetry/temperature/TEMP-001",
        username="temp01",
        normal_rate_per_min=(1, 5),
        value_range=(20.0, 35.0),
        unit="C",
        value_type="float",
    ),
    "HUM-001": DeviceSpec(
        device_id="HUM-001",
        device_type="humidity",
        topic="iot/telemetry/humidity/HUM-001",
        username="hum01",
        normal_rate_per_min=(1, 5),
        value_range=(40.0, 70.0),
        unit="%",
        value_type="float",
    ),
    "MOTION-001": DeviceSpec(
        device_id="MOTION-001",
        device_type="motion",
        topic="iot/telemetry/motion/MOTION-001",
        username="motion01",
        normal_rate_per_min=(1, 10),
        value_range=None,
        unit="",
        value_type="bool",
    ),
    "DOOR-001": DeviceSpec(
        device_id="DOOR-001",
        device_type="door",
        topic="iot/telemetry/door/DOOR-001",
        username="door01",
        normal_rate_per_min=(1, 5),
        value_range=None,
        unit="",
        value_type="enum",
        enum_values=("open", "closed"),
    ),
    "CAM-001": DeviceSpec(
        device_id="CAM-001",
        device_type="camera",
        topic="iot/telemetry/camera/CAM-001",
        username="camera01",
        normal_rate_per_min=(1, 5),
        value_range=None,
        unit="",
        value_type="enum",
        enum_values=("online", "offline"),
    ),
    "LIGHT-001": DeviceSpec(
        device_id="LIGHT-001",
        device_type="light",
        topic="iot/telemetry/light/LIGHT-001",
        username="light01",
        normal_rate_per_min=(1, 5),
        value_range=None,
        unit="",
        value_type="enum",
        enum_values=("on", "off"),
    ),
}

# Anomaly thresholds (project simulation parameters)
TEMP_ANOMALY_THRESHOLD = float(os.getenv("TEMP_ANOMALY_THRESHOLD", "50"))
HUM_ANOMALY_THRESHOLD = float(os.getenv("HUM_ANOMALY_THRESHOLD", "95"))
RATE_ANOMALY_MULTIPLIER = int(os.getenv("RATE_ANOMALY_MULTIPLIER", "10"))

# Security topics (must not be written by devices)
SECURITY_TOPICS = (
    "iot/security/events",
    "iot/security/alerts",
    "iot/security/incidents",
)

COMMAND_PREFIX = "iot/command/"
TELEMETRY_PREFIX = "iot/telemetry/"

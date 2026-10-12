"""Unit tests for telemetry models and validation."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from simulator.models import TelemetryMessage, SecurityEvent, utc_now_iso


def test_telemetry_valid():
    msg = TelemetryMessage(
        device_id="TEMP-001",
        device_type="temperature",
        value=25.5,
        unit="C",
        timestamp=utc_now_iso(),
        sequence=1,
    )
    assert msg.validate() == []
    d = msg.to_dict()
    assert d["device_id"] == "TEMP-001"
    assert d["value"] == 25.5


def test_telemetry_missing_fields():
    msg = TelemetryMessage(
        device_id="",
        device_type="temperature",
        value=None,
        unit="C",
        timestamp="2026-01-01T00:00:00",  # missing Z
        sequence=-1,
    )
    errors = msg.validate()
    assert len(errors) >= 2


def test_security_event_create():
    e = SecurityEvent.create(
        device_id="TEMP-001",
        event_type="SENSOR_VALUE_ANOMALY",
        severity="MEDIUM",
        risk_score=15,
        description="test",
    )
    assert e.event_id.startswith("EVT-")
    assert e.risk_score == 15
    assert e.status == "OPEN"


def test_risk_cap():
    e = SecurityEvent.create(
        device_id="X",
        event_type="TEST",
        severity="CRITICAL",
        risk_score=150,
        description="cap",
    )
    assert e.risk_score == 100

"""Data models for telemetry and security events."""
from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Any, Dict, Optional
import uuid


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


@dataclass
class TelemetryMessage:
    device_id: str
    device_type: str
    value: Any
    unit: str
    timestamp: str
    sequence: int
    client_instance: str = "default"

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    def validate(self) -> list[str]:
        errors: list[str] = []
        required = ("device_id", "device_type", "timestamp", "sequence", "value")
        for f in required:
            if getattr(self, f, None) is None:
                errors.append(f"missing field: {f}")
        if not isinstance(self.sequence, int) or self.sequence < 0:
            errors.append("sequence must be non-negative integer")
        if not self.timestamp.endswith("Z"):
            errors.append("timestamp must be UTC ISO8601 ending with Z")
        return errors


@dataclass
class SecurityEvent:
    event_id: str
    timestamp: str
    device_id: str
    event_type: str
    severity: str
    risk_score: int
    description: str
    source: str = "node-red-detection-engine"
    status: str = "OPEN"
    correlation_id: Optional[str] = None
    mqtt_topic: Optional[str] = None
    observed_value: Optional[Any] = None
    expected_value: Optional[Any] = None
    action: Optional[str] = None

    @staticmethod
    def create(
        device_id: str,
        event_type: str,
        severity: str,
        risk_score: int,
        description: str,
        **kwargs: Any,
    ) -> "SecurityEvent":
        return SecurityEvent(
            event_id=f"EVT-{uuid.uuid4().hex[:8].upper()}",
            timestamp=utc_now_iso(),
            device_id=device_id,
            event_type=event_type,
            severity=severity,
            risk_score=min(100, max(0, risk_score)),
            description=description,
            **kwargs,
        )

    def to_dict(self) -> Dict[str, Any]:
        return {k: v for k, v in asdict(self).items() if v is not None}

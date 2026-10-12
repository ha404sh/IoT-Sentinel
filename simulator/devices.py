"""Device simulation helpers."""
from __future__ import annotations

import random
from typing import Any, Dict

from .config import DEVICES, DeviceSpec
from .models import TelemetryMessage, utc_now_iso


class DeviceSimulator:
    def __init__(self, device_id: str) -> None:
        if device_id not in DEVICES:
            raise ValueError(f"Unknown device_id: {device_id}")
        self.spec: DeviceSpec = DEVICES[device_id]
        self.sequence = 0

    def next_normal_value(self) -> Any:
        s = self.spec
        if s.value_type == "float":
            assert s.value_range is not None
            low, high = s.value_range
            return round(random.uniform(low, high), 1)
        if s.value_type == "bool":
            return random.choice([True, False])
        if s.value_type == "enum":
            return random.choice(s.enum_values)
        raise ValueError(f"Unsupported value_type: {s.value_type}")

    def build_telemetry(self, value: Any | None = None, client_instance: str = "default") -> TelemetryMessage:
        self.sequence += 1
        if value is None:
            value = self.next_normal_value()
        return TelemetryMessage(
            device_id=self.spec.device_id,
            device_type=self.spec.device_type,
            value=value,
            unit=self.spec.unit,
            timestamp=utc_now_iso(),
            sequence=self.sequence,
            client_instance=client_instance,
        )

    def topic(self) -> str:
        return self.spec.topic

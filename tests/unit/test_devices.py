"""Unit tests for device simulator."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from simulator.devices import DeviceSimulator


def test_temp_range():
    sim = DeviceSimulator("TEMP-001")
    for _ in range(20):
        v = sim.next_normal_value()
        assert 20.0 <= v <= 35.0


def test_sequence_increments():
    sim = DeviceSimulator("HUM-001")
    m1 = sim.build_telemetry()
    m2 = sim.build_telemetry()
    assert m2.sequence == m1.sequence + 1


def test_unknown_device_raises():
    try:
        DeviceSimulator("TEMP-999")
        assert False, "should raise"
    except ValueError:
        pass

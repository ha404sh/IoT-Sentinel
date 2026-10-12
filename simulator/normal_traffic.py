"""Generate normal telemetry traffic for all registered devices."""
from __future__ import annotations

import logging
import time
from typing import Dict, List

from .config import DEVICES, MQTTConfig
from .devices import DeviceSimulator
from .mqtt_client import SafeMQTTClient

logger = logging.getLogger("iot-sentinel.normal")


def run_normal(duration_sec: int = 300, interval_sec: float = 5.0) -> None:
    """Publish normal telemetry for all 6 devices."""
    config = MQTTConfig()
    clients: Dict[str, SafeMQTTClient] = {}
    sims: Dict[str, DeviceSimulator] = {}

    try:
        for device_id, spec in DEVICES.items():
            client = SafeMQTTClient(config, client_id=f"sim-{device_id}")
            # In bootstrap mode we connect anonymously; later with credentials
            client.connect()
            clients[device_id] = client
            sims[device_id] = DeviceSimulator(device_id)
            logger.info("Started simulator for %s", device_id)

        end = time.time() + duration_sec
        while time.time() < end:
            for device_id, sim in sims.items():
                msg = sim.build_telemetry()
                clients[device_id].publish(sim.topic(), msg.to_dict())
                logger.info("Normal telemetry: %s value=%s seq=%s", device_id, msg.value, msg.sequence)
            time.sleep(interval_sec)
    finally:
        for c in clients.values():
            c.disconnect()
        logger.info("Normal traffic stopped")

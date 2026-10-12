"""Safe MQTT client wrapper. Only connects to local project broker."""
from __future__ import annotations

import json
import logging
import ssl
import time
from typing import Any, Callable, Optional

import paho.mqtt.client as mqtt

from .config import MQTTConfig

logger = logging.getLogger("iot-sentinel.mqtt")


class SafeMQTTClient:
    """MQTT client restricted to the project's local broker."""

    def __init__(self, config: Optional[MQTTConfig] = None, client_id: str = "iot-sentinel-sim") -> None:
        self.config = config or MQTTConfig()
        self.client_id = client_id
        self._client: Optional[mqtt.Client] = None
        self._connected = False

    def _validate_host(self) -> None:
        if self.config.host not in self.config.allowed_hosts:
            raise RuntimeError(
                f"Safety lock: refusing to connect to non-local host '{self.config.host}'. "
                f"Allowed: {self.config.allowed_hosts}"
            )

    def connect(self, username: str = "", password: str = "") -> None:
        self._validate_host()
        self._client = mqtt.Client(
            callback_api_version=mqtt.CallbackAPIVersion.VERSION2,
            client_id=self.client_id,
            protocol=mqtt.MQTTv311,
        )
        if username:
            self._client.username_pw_set(username, password)

        if self.config.use_tls:
            # TLS setup – certificates must be present for final secure mode
            context = ssl.create_default_context()
            # In development we may need to relax; final mode must verify
            self._client.tls_set_context(context)
            port = self.config.tls_port
        else:
            port = self.config.port

        self._client.on_connect = self._on_connect
        self._client.on_disconnect = self._on_disconnect

        logger.info("Connecting to %s:%s (client_id=%s)", self.config.host, port, self.client_id)
        self._client.connect(self.config.host, port, keepalive=self.config.keepalive)
        self._client.loop_start()
        # Wait briefly for connection
        for _ in range(20):
            if self._connected:
                break
            time.sleep(0.1)
        if not self._connected:
            raise ConnectionError("Failed to connect to MQTT broker within timeout")

    def _on_connect(self, client: mqtt.Client, userdata: Any, flags: Any, reason_code: Any, properties: Any = None) -> None:
        if reason_code == 0 or str(reason_code) == "Success":
            self._connected = True
            logger.info("MQTT connected")
        else:
            logger.error("MQTT connect failed: %s", reason_code)
            self._connected = False

    def _on_disconnect(self, client: mqtt.Client, userdata: Any, flags: Any, reason_code: Any, properties: Any = None) -> None:
        self._connected = False
        logger.warning("MQTT disconnected: %s", reason_code)

    def publish(self, topic: str, payload: dict | str, qos: int = 0, retain: bool = False) -> None:
        if not self._client or not self._connected:
            raise RuntimeError("Not connected")
        data = json.dumps(payload) if isinstance(payload, dict) else payload
        result = self._client.publish(topic, data, qos=qos, retain=retain)
        if result.rc != mqtt.MQTT_ERR_SUCCESS:
            raise RuntimeError(f"Publish failed: rc={result.rc}")
        logger.debug("Published to %s", topic)

    def disconnect(self) -> None:
        if self._client:
            self._client.loop_stop()
            self._client.disconnect()
            self._connected = False
            logger.info("MQTT disconnected cleanly")

    @property
    def is_connected(self) -> bool:
        return self._connected

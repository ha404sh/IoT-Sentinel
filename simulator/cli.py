"""CLI entry point for IoT Sentinel simulator."""
from __future__ import annotations

import argparse
import logging
import sys

from . import attack_simulator as attacks
from .normal_traffic import run_normal

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%SZ",
)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="IoT Sentinel Simulator (local lab only)")
    sub = parser.add_subparsers(dest="command", required=True)

    # normal
    p_normal = sub.add_parser("normal", help="Generate normal telemetry")
    p_normal.add_argument("--duration", type=int, default=300, help="Seconds to run")
    p_normal.add_argument("--interval", type=float, default=5.0, help="Interval between rounds")

    # attack
    p_attack = sub.add_parser("attack", help="Run a controlled attack scenario")
    p_attack.add_argument(
        "scenario",
        choices=["flood", "abnormal-value", "unauthorized-device", "topic-abuse", "spoofing", "auth-failure"],
    )
    p_attack.add_argument("--device", default="TEMP-001")
    p_attack.add_argument("--count", type=int, default=200, help="Flood message count")
    p_attack.add_argument("--value", type=float, default=150.0, help="Abnormal value")

    args = parser.parse_args(argv)

    if args.command == "normal":
        run_normal(duration_sec=args.duration, interval_sec=args.interval)
        return 0

    if args.command == "attack":
        if args.scenario == "flood":
            attacks.attack_flood(device_id=args.device, count=args.count)
        elif args.scenario == "abnormal-value":
            attacks.attack_abnormal_value(device_id=args.device, value=args.value)
        elif args.scenario == "unauthorized-device":
            attacks.attack_unauthorized_device()
        elif args.scenario == "topic-abuse":
            attacks.attack_topic_abuse(device_id=args.device)
        elif args.scenario == "spoofing":
            attacks.attack_spoofing(device_id=args.device)
        elif args.scenario == "auth-failure":
            attacks.attack_auth_failure(device_id=args.device)
        return 0

    return 1


if __name__ == "__main__":
    sys.exit(main())

# 01 – Project Overview

## Title
IoT Sentinel: A Node-RED-Based IoT Security Monitoring, Anomaly Detection, and Automated Response System

## Positioning
IoT Sentinel is a local IoT security monitoring and response platform that analyzes MQTT-based telemetry, establishes expected device behavior, detects predefined anomalous and malicious scenarios, correlates security events, calculates risk, records incidents, and performs logical containment within a controlled simulated environment.

## Goals
- Provide a reproducible, testable IoT security monitoring pipeline.
- Demonstrate defense-in-depth for MQTT-based IoT (broker controls + application detection).
- Implement deterministic risk scoring and automated logical response.
- Support academic evaluation through documented attack scenarios and acceptance tests.

## Non-Goals
- Physical device isolation
- Production-grade ML/AI anomaly detection
- Enterprise SIEM integration (Elastic, Splunk, etc.)
- Cloud dependency

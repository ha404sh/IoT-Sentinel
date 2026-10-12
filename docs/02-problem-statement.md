# 02 – Problem Statement

## Context

Internet of Things deployments continue to expand in homes, factories, and critical infrastructure. Many of these systems rely on MQTT as a lightweight publish/subscribe transport. Default broker configurations frequently allow anonymous connections. Device firmware often ships with hard-coded credentials or no credentials at all. Operators typically lack continuous visibility into whether a sensor is behaving within expected bounds, whether an unknown identity has appeared on the bus, or whether a flood of messages is underway.

## Security gap

Traditional enterprise SIEM platforms can ingest MQTT telemetry, but they are heavyweight for academic laboratories and student projects. They also assume organizational processes for incident response that may not exist in a course setting. At the other extreme, pure hardware demos with ESP32 boards prove connectivity but rarely implement a full detection and response pipeline that can be graded, reproduced, and audited.

The missing middle is a **local, reproducible platform** that:

1. Accepts structured MQTT telemetry from multiple logical devices.
2. Validates message schema, device identity, and topic authorization.
3. Maintains behavioral baselines (rate, value, client instance).
4. Detects predefined attack and anomaly scenarios without fabricating results.
5. Scores risk deterministically and performs **logical** containment.
6. Records evidence for academic review.

## Why this matters academically

Students and researchers need a system they can clone, start with Docker Compose, and exercise with scripted attacks. Claims such as “AI-powered prevention of all cyber attacks” are not academically defensible without corresponding methods and evidence. A rule-based pipeline with honest limitations is a stronger educational artifact.

## Scope of IoT Sentinel

IoT Sentinel addresses the gap above within a controlled simulation. It does not replace physical network segmentation, does not claim zero false negatives, and does not require cloud services for core operation. Its contribution is an integrated, testable path from device simulation through broker security controls to detection, risk, response, and operator visibility.


## Stakeholders

- Academic instructors evaluating reproducible IoT security labs
- Students learning MQTT security controls and detection engineering
- Researchers prototyping rule-based IoT monitoring without SIEM cost

## Threat scenarios in scope

Unauthorized identity, abnormal telemetry values, message floods, topic abuse, identity spoofing heuristics, failed authentication (Stage B), and correlated multi-signal incidents.

## Threats out of scope

Internet-wide scanning, exploitation of broker CVEs, physical tampering, supply-chain attacks on device firmware, and cloud-native lateral movement. Those topics belong to other courses or production hardening programs.

## Success criteria for the problem statement

A third party can clone the repository, start the stack, run the simulator and attacks, and observe corresponding security events without undocumented manual steps beyond the documented scripts.

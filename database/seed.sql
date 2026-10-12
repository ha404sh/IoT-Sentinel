-- Seed initial device registry
INSERT OR IGNORE INTO devices (device_id, device_type, status, risk_score, first_seen, last_seen, allowed_topics, normal_message_rate, expected_value_range)
VALUES
('TEMP-001', 'temperature', 'ACTIVE', 0, NULL, NULL, 'iot/telemetry/temperature/TEMP-001', '1-5/min', '20-35 C'),
('HUM-001',  'humidity',    'ACTIVE', 0, NULL, NULL, 'iot/telemetry/humidity/HUM-001',    '1-5/min', '40-70 %'),
('MOTION-001','motion',     'ACTIVE', 0, NULL, NULL, 'iot/telemetry/motion/MOTION-001',   '1-10/min', 'true/false'),
('DOOR-001', 'door',        'ACTIVE', 0, NULL, NULL, 'iot/telemetry/door/DOOR-001',       '1-5/min', 'open/closed'),
('CAM-001',  'camera',      'ACTIVE', 0, NULL, NULL, 'iot/telemetry/camera/CAM-001',      '1-5/min', 'online/offline'),
('LIGHT-001','light',       'ACTIVE', 0, NULL, NULL, 'iot/telemetry/light/LIGHT-001',     '1-5/min', 'on/off');

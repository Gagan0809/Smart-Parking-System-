# Smart Parking: IoT + Real-Time Setup

## Render environment variables

Keep the existing variables:

- `MONGODB_URI`
- `JWT_SECRET`

Add:

- `IOT_DEVICE_KEY` = a long random value shared only by Render and the ESP32.
- `PARKING_TIME_ZONE` = `Asia/Kolkata` for this project.

## IoT endpoints

ESP32 status upload:

`POST /api/iot/parking-status`

Header:

`X-IOT-KEY: <IOT_DEVICE_KEY>`

ESP32 booking-state polling:

`GET /api/iot/parking-state`

Header:

`X-IOT-KEY: <IOT_DEVICE_KEY>`

Status inspection:

`GET /api/iot/parking-status`

Header:

`X-IOT-KEY: <IOT_DEVICE_KEY>`

## WebSocket

Flutter connects to:

`wss://smart-parking-system-9mbk.onrender.com/ws/parking`

The server sends a JSON event with `type = parking_update` and a `slots` array. The Flutter controller applies the updates immediately and reconnects after temporary network failures.

## ESP32 configuration

In the Arduino sketch set:

`ssid` = your Wi-Fi name

`password` = your Wi-Fi password

`IOT_DEVICE_KEY` = exactly the value configured in Render

The sketch already uses the HTTPS Render backend, uploads ultrasonic occupancy, polls booking state, and drives the reservation LEDs.

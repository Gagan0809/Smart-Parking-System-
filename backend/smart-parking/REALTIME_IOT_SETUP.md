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

## Local Windows PowerShell setup

Set these variables in the same PowerShell window used to start Maven or the application:

```powershell
$env:MONGODB_URI = "mongodb+srv://<username>:<password>@<cluster>/<database>?retryWrites=true&w=majority"
$env:JWT_SECRET = "<random-secret-at-least-32-characters-long>"
$env:IOT_DEVICE_KEY = "<your-long-random-iot-device-key>"
```

Then build and run:

```powershell
.\mvnw.cmd clean package
java -jar target\smart-parking-0.0.1-SNAPSHOT.jar
```

Do not put secret values in `application.properties`, source code, screenshots, or Git. Configure the same `IOT_DEVICE_KEY` value in the ESP32 sketch and as the `X-IOT-KEY` header in Postman. The backend does not use a development fallback key when the variable is missing.

The application context test supplies isolated test-only configuration and uses a local MongoDB URI. It does not require production credentials. The test does not perform database operations, so it does not require a running local MongoDB server.

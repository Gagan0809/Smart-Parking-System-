package com.gagan.smartparking.controller;

import com.gagan.smartparking.realtime.ParkingRealtimeService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/iot")
@CrossOrigin(origins = "*")
public class IotController {

    private final ParkingRealtimeService parkingRealtimeService;
    private final String iotDeviceKey;

    public IotController(
            ParkingRealtimeService parkingRealtimeService,
            @Value("${iot.device-key:dev-iot-key}") String iotDeviceKey) {
        this.parkingRealtimeService = parkingRealtimeService;
        this.iotDeviceKey = iotDeviceKey;
    }

    @PostMapping("/parking-status")
    public ResponseEntity<?> updateParkingStatus(
            @RequestHeader(value = "X-IOT-KEY", required = false) String suppliedKey,
            @RequestBody Map<String, Object> payload) {

        if (!iotDeviceKey.equals(suppliedKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Invalid IoT device key"));
        }

        Object rawSlots = payload.get("slots");
        if (!(rawSlots instanceof List<?> rawList)) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "slots must be an array"));
        }

        List<Map<String, Object>> slots = new ArrayList<>();
        for (Object item : rawList) {
            if (item instanceof Map<?, ?> rawMap) {
                Map<String, Object> normalized = new LinkedHashMap<>();
                for (Map.Entry<?, ?> entry : rawMap.entrySet()) {
                    if (entry.getKey() != null) {
                        normalized.put(entry.getKey().toString(), entry.getValue());
                    }
                }
                slots.add(normalized);
            }
        }

        Map<String, Object> snapshot = parkingRealtimeService.recordIoTStatus(
                payload.get("deviceId") == null ? null : payload.get("deviceId").toString(),
                slots,
                asBoolean(payload.get("gateOpen")),
                asBoolean(payload.get("entryDetected")),
                asBoolean(payload.get("exitDetected")));

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("message", "Parking status updated");
        response.put("data", snapshot);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/parking-status")
    public ResponseEntity<Map<String, Object>> getParkingStatus(
            @RequestHeader(value = "X-IOT-KEY", required = false) String suppliedKey) {

        if (!iotDeviceKey.equals(suppliedKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        return ResponseEntity.ok(parkingRealtimeService.getCurrentSnapshot());
    }

    @GetMapping("/parking-state")
    public ResponseEntity<?> getParkingState(
            @RequestHeader(value = "X-IOT-KEY", required = false) String suppliedKey) {

        if (!iotDeviceKey.equals(suppliedKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Invalid IoT device key"));
        }

        return ResponseEntity.ok(parkingRealtimeService.getBookingState());
    }

    private Boolean asBoolean(Object value) {
        if (value instanceof Boolean bool) {
            return bool;
        }

        if (value == null) {
            return false;
        }

        return Boolean.parseBoolean(value.toString());
    }
}

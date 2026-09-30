package com.gagan.smartparking.realtime;

import com.gagan.smartparking.model.ParkingSlot;
import com.gagan.smartparking.repository.BookingRepository;
import com.gagan.smartparking.repository.ParkingSlotRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ParkingRealtimeService {

    private final ParkingSlotRepository parkingSlotRepository;
    private final BookingRepository bookingRepository;
    private final ParkingWebSocketHandler webSocketHandler;
    private final ZoneId zoneId;

    private final Map<String, Double> latestDistances = new ConcurrentHashMap<>();

    private volatile String latestDeviceId = "ESP32_PARKING_01";
    private volatile boolean latestGateOpen;
    private volatile boolean latestEntryDetected;
    private volatile boolean latestExitDetected;
    private volatile String latestIoTUpdate = null;

    public ParkingRealtimeService(
            ParkingSlotRepository parkingSlotRepository,
            BookingRepository bookingRepository,
            ParkingWebSocketHandler webSocketHandler,
            @Value("${parking.time-zone:Asia/Kolkata}") String timeZone) {
        this.parkingSlotRepository = parkingSlotRepository;
        this.bookingRepository = bookingRepository;
        this.webSocketHandler = webSocketHandler;
        ZoneId resolvedZone;
        try {
            resolvedZone = ZoneId.of(timeZone);
        } catch (Exception ignored) {
            resolvedZone = ZoneId.of("Asia/Kolkata");
        }
        this.zoneId = resolvedZone;
    }

    public synchronized Map<String, Object> recordIoTStatus(
            String deviceId,
            List<Map<String, Object>> slotReadings,
            Boolean gateOpen,
            Boolean entryDetected,
            Boolean exitDetected) {

        latestDeviceId = isBlank(deviceId) ? "ESP32_PARKING_01" : deviceId;
        latestGateOpen = Boolean.TRUE.equals(gateOpen);
        latestEntryDetected = Boolean.TRUE.equals(entryDetected);
        latestExitDetected = Boolean.TRUE.equals(exitDetected);

        for (Map<String, Object> reading : slotReadings) {
            String slotId = stringValue(reading.get("slotId")).trim();
            if (slotId.isEmpty()) {
                continue;
            }

            ParkingSlot slot = parkingSlotRepository.findAll().stream()
                    .filter(item -> item.getSlotId() != null
                            && item.getSlotId().equalsIgnoreCase(slotId))
                    .findFirst()
                    .orElse(null);

            if (slot == null) {
                continue;
            }

            boolean occupied = Boolean.TRUE.equals(reading.get("occupied"));
            if (!"maintenance".equalsIgnoreCase(slot.getStatus())) {
                slot.setStatus(occupied ? "Occupied" : "Available");
                parkingSlotRepository.save(slot);
            }

            Double distance = doubleValue(reading.get("distance"));
            if (distance != null && distance >= 0) {
                latestDistances.put(normalizeKey(slotId), distance);
            }
        }

        latestIoTUpdate = LocalDateTime.now(zoneId).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);

        Map<String, Object> snapshot = buildSnapshot();
        webSocketHandler.broadcast(snapshot);
        return snapshot;
    }

    public Map<String, Object> getCurrentSnapshot() {
        return buildSnapshot();
    }

    public Map<String, Object> buildSnapshot() {
        List<Map<String, Object>> slots = new ArrayList<>();

        for (ParkingSlot slot : parkingSlotRepository.findAll()) {
            String slotId = slot.getSlotId() == null ? "" : slot.getSlotId();
            boolean occupied = "occupied".equalsIgnoreCase(slot.getStatus());
            boolean reserved = hasActiveOrUpcomingBooking(slotId);

            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("slotId", slotId);
            entry.put("occupied", occupied);
            entry.put("reserved", reserved);
            entry.put("status", occupied ? "Occupied" : (reserved ? "Reserved" : normalizeStatus(slot.getStatus())));

            Double distance = latestDistances.get(normalizeKey(slotId));
            if (distance != null) {
                entry.put("distance", distance);
            }

            entry.put("location", slot.getLocation());
            entry.put("price", slot.getPrice());
            entry.put("latitude", slot.getLatitude());
            entry.put("longitude", slot.getLongitude());
            entry.put("timeSlots", slot.getTimeSlots());
            slots.add(entry);
        }

        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("type", "parking_update");
        snapshot.put("deviceId", latestDeviceId);
        snapshot.put("timestamp", LocalDateTime.now(zoneId).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        snapshot.put("gateOpen", latestGateOpen);
        snapshot.put("entryDetected", latestEntryDetected);
        snapshot.put("exitDetected", latestExitDetected);
        snapshot.put("connectedClients", webSocketHandler.getConnectedClientCount());
        snapshot.put("slots", slots);
        return snapshot;
    }

    public Map<String, Object> getBookingState() {
        List<Map<String, Object>> slots = new ArrayList<>();

        for (ParkingSlot slot : parkingSlotRepository.findAll()) {
            String slotId = slot.getSlotId() == null ? "" : slot.getSlotId();
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("slotId", slotId);
            entry.put("reserved", hasActiveOrUpcomingBooking(slotId));
            slots.add(entry);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("slots", slots);
        response.put("timestamp", LocalDateTime.now(zoneId).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        return response;
    }

    public void broadcastCurrentState() {
        webSocketHandler.broadcast(buildSnapshot());
    }

    public String getLatestIoTUpdate() {
        return latestIoTUpdate;
    }

    private boolean hasActiveOrUpcomingBooking(String slotId) {
        if (isBlank(slotId)) {
            return false;
        }

        LocalDateTime now = LocalDateTime.now(zoneId);

        return bookingRepository.findBySlotId(slotId).stream().anyMatch(booking -> {
            LocalDateTime exit = parseDateTime(booking.getExitDate(), booking.getExitTime());
            return exit == null || !exit.isBefore(now);
        });
    }

    private LocalDateTime parseDateTime(String date, String time) {
        if (isBlank(date) || isBlank(time)) {
            return null;
        }

        try {
            String normalizedTime = time.trim();
            if (normalizedTime.length() == 4) {
                normalizedTime = "0" + normalizedTime;
            }
            return LocalDate.parse(date.trim(), DateTimeFormatter.ISO_LOCAL_DATE)
                    .atTime(LocalTime.parse(normalizedTime, DateTimeFormatter.ISO_LOCAL_TIME));
        } catch (Exception ignored) {
            return null;
        }
    }

    private String normalizeStatus(String status) {
        if (isBlank(status)) {
            return "Available";
        }

        String value = status.trim().toLowerCase();
        return switch (value) {
            case "occupied", "busy" -> "Occupied";
            case "reserved" -> "Reserved";
            case "maintenance" -> "Maintenance";
            default -> "Available";
        };
    }

    private String normalizeKey(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    private String stringValue(Object value) {
        return value == null ? "" : value.toString();
    }

    private Double doubleValue(Object value) {
        if (value instanceof Number number) {
            return number.doubleValue();
        }

        if (value == null) {
            return null;
        }

        try {
            return Double.parseDouble(value.toString());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}

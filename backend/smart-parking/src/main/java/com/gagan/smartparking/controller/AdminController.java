package com.gagan.smartparking.controller;

import com.gagan.smartparking.model.Booking;
import com.gagan.smartparking.model.ParkingLocation;
import com.gagan.smartparking.model.ParkingSlot;
import com.gagan.smartparking.model.User;
import com.gagan.smartparking.repository.BookingRepository;
import com.gagan.smartparking.repository.ParkingLocationRepository;
import com.gagan.smartparking.repository.ParkingSlotRepository;
import com.gagan.smartparking.repository.UserRepository;
import com.gagan.smartparking.security.JwtService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private final ParkingLocationRepository parkingLocationRepository;
    private final ParkingSlotRepository parkingSlotRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;
    private final JwtService jwtService;
    private final String adminEmail;
    private final String adminPassword;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AdminController(
            ParkingLocationRepository parkingLocationRepository,
            ParkingSlotRepository parkingSlotRepository,
            UserRepository userRepository,
            BookingRepository bookingRepository,
            JwtService jwtService,
            @Value("${admin.email:admin@smartparking.com}") String adminEmail,
            @Value("${admin.password:admin123}") String adminPassword) {
        this.parkingLocationRepository = parkingLocationRepository;
        this.parkingSlotRepository = parkingSlotRepository;
        this.userRepository = userRepository;
        this.bookingRepository = bookingRepository;
        this.jwtService = jwtService;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, Object> request) {
        String email = stringValue(request.get("email")).trim();
        String password = stringValue(request.get("password"));

        if (email.isEmpty() || password.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Email and password are required"));
        }

        boolean configuredAdmin =
                adminEmail.equalsIgnoreCase(email) && adminPassword.equals(password);

        User databaseAdmin = null;
        if (!configuredAdmin) {
            Optional<User> databaseUser = userRepository.findByEmail(email);
            if (databaseUser.isPresent()
                    && "ADMIN".equalsIgnoreCase(databaseUser.get().getRole())
                    && databaseUser.get().getPassword() != null
                    && passwordEncoder.matches(password, databaseUser.get().getPassword())) {
                databaseAdmin = databaseUser.get();
            }
        }

        if (!configuredAdmin && databaseAdmin == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Invalid admin email or password"));
        }

        String authenticatedEmail = configuredAdmin
                ? adminEmail
                : databaseAdmin.getEmail();
        String authenticatedName = configuredAdmin
                ? "Admin"
                : (databaseAdmin.getName() == null || databaseAdmin.getName().isBlank()
                        ? "Admin"
                        : databaseAdmin.getName());

        String token = jwtService.generateToken(authenticatedEmail, "ADMIN");

        Map<String, Object> adminUser = new LinkedHashMap<>();
        if (databaseAdmin != null) {
            adminUser.put("id", databaseAdmin.getId());
        }
        adminUser.put("name", authenticatedName);
        adminUser.put("email", authenticatedEmail);
        adminUser.put("role", "ADMIN");

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("message", "Admin login successful");
        response.put("token", token);
        response.put("user", adminUser);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/parking-locations")
    public ResponseEntity<List<ParkingLocation>> getParkingLocations() {
        List<ParkingLocation> locations = parkingLocationRepository.findAll();

        for (ParkingLocation location : locations) {
            String locationName = location.getName();
            int slotCount = locationName == null || locationName.isBlank()
                    ? 0
                    : (int) parkingSlotRepository.countByLocationIgnoreCase(locationName);
            location.setSlots(slotCount);
        }

        return ResponseEntity.ok(locations);
    }

    @PostMapping("/parking-locations")
    public ResponseEntity<?> addParkingLocation(@RequestBody ParkingLocation location) {
        String name = stringValue(location.getName()).trim();
        String address = stringValue(location.getAddress()).trim();

        if (name.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Parking location name is required"));
        }

        if (parkingLocationRepository.existsByNameIgnoreCase(name)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "A parking location with this name already exists"));
        }

        location.setName(name);
        location.setAddress(address);
        location.setSlots((int) parkingSlotRepository.countByLocationIgnoreCase(name));
        location.setStatus(normalizeStatus(location.getStatus()));

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(parkingLocationRepository.save(location));
    }

    @PutMapping("/parking-locations/{id}")
    public ResponseEntity<?> updateParkingLocation(
            @PathVariable String id,
            @RequestBody ParkingLocation updatedLocation) {

        Optional<ParkingLocation> existingOptional =
                parkingLocationRepository.findById(id);

        if (existingOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ParkingLocation existing = existingOptional.get();
        String oldName = stringValue(existing.getName()).trim();
        String newName = stringValue(updatedLocation.getName()).trim();
        String address = stringValue(updatedLocation.getAddress()).trim();

        if (newName.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Parking location name is required"));
        }

        Optional<ParkingLocation> duplicate =
                parkingLocationRepository.findByNameIgnoreCase(newName);

        if (duplicate.isPresent() && !id.equals(duplicate.get().getId())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "A parking location with this name already exists"));
        }

        if (!oldName.equalsIgnoreCase(newName)) {
            List<ParkingSlot> slots = new ArrayList<>(
                    parkingSlotRepository.findAll().stream()
                            .filter(slot -> slot.getLocation() != null
                                    && slot.getLocation().equalsIgnoreCase(oldName))
                            .toList());

            for (ParkingSlot slot : slots) {
                slot.setLocation(newName);
                parkingSlotRepository.save(slot);
            }
        }

        existing.setName(newName);
        existing.setAddress(address);
        existing.setStatus(normalizeStatus(updatedLocation.getStatus()));
        existing.setLatitude(updatedLocation.getLatitude());
        existing.setLongitude(updatedLocation.getLongitude());
        existing.setSlots((int) parkingSlotRepository.countByLocationIgnoreCase(newName));

        return ResponseEntity.ok(parkingLocationRepository.save(existing));
    }

    @DeleteMapping("/parking-locations/{id}")
    public ResponseEntity<?> deleteParkingLocation(@PathVariable String id) {
        Optional<ParkingLocation> locationOptional =
                parkingLocationRepository.findById(id);

        if (locationOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ParkingLocation location = locationOptional.get();
        long assignedSlots = location.getName() == null
                ? 0
                : parkingSlotRepository.countByLocationIgnoreCase(location.getName());

        if (assignedSlots > 0) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "Cannot delete a location while parking slots are assigned to it"));
        }

        parkingLocationRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/parking-slots")
    public ResponseEntity<List<ParkingSlot>> getParkingSlots() {
        return ResponseEntity.ok(parkingSlotRepository.findAll());
    }

    @PostMapping("/parking-slots")
    public ResponseEntity<?> addParkingSlot(@RequestBody ParkingSlot slot) {
        String slotId = stringValue(slot.getSlotId()).trim();
        String location = stringValue(slot.getLocation()).trim();

        if (slotId.isEmpty() || location.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Slot ID and location are required"));
        }

        if (parkingSlotRepository.existsBySlotIdIgnoreCase(slotId)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "A parking slot with this slot ID already exists"));
        }

        slot.setSlotId(slotId);
        slot.setLocation(location);
        slot.setStatus(normalizeSlotStatus(slot.getStatus()));
        slot.setPrice(normalizePrice(slot.getPrice()));

        ParkingSlot saved = parkingSlotRepository.save(slot);
        syncLocationCount(location);

        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/parking-slots/{id}")
    public ResponseEntity<?> updateParkingSlot(
            @PathVariable String id,
            @RequestBody ParkingSlot updatedSlot) {

        Optional<ParkingSlot> existingOptional = parkingSlotRepository.findById(id);

        if (existingOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ParkingSlot existing = existingOptional.get();
        String newSlotId = stringValue(updatedSlot.getSlotId()).trim();
        String oldLocation = stringValue(existing.getLocation()).trim();
        String newLocation = stringValue(updatedSlot.getLocation()).trim();

        if (newSlotId.isEmpty() || newLocation.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Slot ID and location are required"));
        }

        Optional<ParkingSlot> duplicate = parkingSlotRepository.findAll().stream()
                .filter(slot -> slot.getSlotId() != null
                        && slot.getSlotId().equalsIgnoreCase(newSlotId)
                        && !id.equals(slot.getId()))
                .findFirst();

        if (duplicate.isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "A parking slot with this slot ID already exists"));
        }

        existing.setSlotId(newSlotId);
        existing.setLocation(newLocation);
        existing.setStatus(normalizeSlotStatus(updatedSlot.getStatus()));
        existing.setPrice(normalizePrice(updatedSlot.getPrice()));
        existing.setLatitude(updatedSlot.getLatitude());
        existing.setLongitude(updatedSlot.getLongitude());
        existing.setTimeSlots(updatedSlot.getTimeSlots());

        ParkingSlot saved = parkingSlotRepository.save(existing);

        if (!oldLocation.equalsIgnoreCase(newLocation)) {
            syncLocationCount(oldLocation);
        }
        syncLocationCount(newLocation);

        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/parking-slots/{id}")
    public ResponseEntity<?> deleteParkingSlot(@PathVariable String id) {
        Optional<ParkingSlot> slotOptional = parkingSlotRepository.findById(id);

        if (slotOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        String location = stringValue(slotOptional.get().getLocation()).trim();
        parkingSlotRepository.deleteById(id);
        syncLocationCount(location);

        return ResponseEntity.noContent().build();
    }

    @GetMapping("/users")
    public ResponseEntity<List<Map<String, Object>>> getUsers() {
        List<Map<String, Object>> response = new ArrayList<>();

        for (User user : userRepository.findAll()) {
            Map<String, Object> safeUser = new LinkedHashMap<>();
            safeUser.put("id", user.getId());
            safeUser.put("name", user.getName());
            safeUser.put("email", user.getEmail());
            safeUser.put("role", user.getRole() == null ? "USER" : user.getRole());
            response.add(safeUser);
        }

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable String id) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        User user = userOptional.get();

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "Admin accounts cannot be deleted here"));
        }

        userRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/bookings")
    public ResponseEntity<List<Booking>> getBookings() {
        return ResponseEntity.ok(bookingRepository.findAll());
    }

    @DeleteMapping("/bookings/{id}")
    public ResponseEntity<?> deleteBooking(@PathVariable String id) {
        Optional<Booking> bookingOptional = bookingRepository.findById(id);

        if (bookingOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Booking booking = bookingOptional.get();
        bookingRepository.deleteById(id);

        freeSlotWhenUnbooked(booking.getSlotId());

        return ResponseEntity.noContent().build();
    }

    private void syncLocationCount(String locationName) {
        if (locationName == null || locationName.isBlank()) {
            return;
        }

        parkingLocationRepository.findByNameIgnoreCase(locationName)
                .ifPresent(location -> {
                    location.setSlots(
                            (int) parkingSlotRepository.countByLocationIgnoreCase(locationName));
                    parkingLocationRepository.save(location);
                });
    }

    private void freeSlotWhenUnbooked(String slotId) {
        if (slotId == null || slotId.isBlank()) {
            return;
        }

        if (!bookingRepository.findBySlotId(slotId).isEmpty()) {
            return;
        }

        parkingSlotRepository.findAll().stream()
                .filter(slot -> slot.getSlotId() != null
                        && slot.getSlotId().equalsIgnoreCase(slotId))
                .findFirst()
                .ifPresent(slot -> {
                    slot.setStatus("Available");
                    parkingSlotRepository.save(slot);
                });
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Active";
        }

        String normalized = status.trim().toLowerCase();
        if ("inactive".equals(normalized)) {
            return "Inactive";
        }

        return "Active";
    }

    private String normalizeSlotStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Available";
        }

        String normalized = status.trim().toLowerCase();
        return switch (normalized) {
            case "occupied", "busy" -> "Occupied";
            case "reserved" -> "Reserved";
            case "maintenance" -> "Maintenance";
            default -> "Available";
        };
    }

    private Double normalizePrice(Double price) {
        if (price == null || price < 0) {
            return 20.0;
        }
        return price;
    }

    private String stringValue(Object value) {
        return value == null ? "" : value.toString();
    }
}

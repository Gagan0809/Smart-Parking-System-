package com.gagan.smartparking.controller;

import com.gagan.smartparking.model.Booking;
import com.gagan.smartparking.model.ParkingSlot;
import com.gagan.smartparking.model.User;
import com.gagan.smartparking.repository.BookingRepository;
import com.gagan.smartparking.repository.ParkingSlotRepository;
import com.gagan.smartparking.repository.UserRepository;
import com.gagan.smartparking.service.BookingAvailabilityService;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*")
public class BookingController {

    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final ParkingSlotRepository parkingSlotRepository;
    private final BookingAvailabilityService bookingAvailabilityService;

    // Serializes booking creation for the same slot inside this backend instance.
    // The conflict check is still performed again immediately before save.
    private final ConcurrentHashMap<String, Object> slotLocks =
            new ConcurrentHashMap<>();

    public BookingController(
            BookingRepository bookingRepository,
            UserRepository userRepository,
            ParkingSlotRepository parkingSlotRepository,
            BookingAvailabilityService bookingAvailabilityService) {
        this.bookingRepository = bookingRepository;
        this.userRepository = userRepository;
        this.parkingSlotRepository = parkingSlotRepository;
        this.bookingAvailabilityService = bookingAvailabilityService;
    }

    /**
     * USER: returns only the authenticated user's bookings.
     * ADMIN: returns all bookings so the admin dashboard can manage them.
     */
    @GetMapping
    public ResponseEntity<?> getBookings(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Authentication is required"));
        }

        if (isAdmin(authentication)) {
            return ResponseEntity.ok(bookingRepository.findAll());
        }

        String authenticatedEmail = authentication.getName();
        if (authenticatedEmail == null || authenticatedEmail.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Authenticated user email is missing"));
        }

        return ResponseEntity.ok(
                bookingRepository.findByUserEmailIgnoreCase(authenticatedEmail));
    }

    /**
     * Optional availability endpoint for the Flutter client.
     * The POST /api/bookings endpoint remains the final authority, so this
     * endpoint should only be used to improve the UI before submission.
     */
    @GetMapping("/availability")
    public ResponseEntity<?> checkAvailability(
            @RequestParam String slotId,
            @RequestParam String entryDate,
            @RequestParam String entryTime,
            @RequestParam String exitDate,
            @RequestParam String exitTime,
            Authentication authentication) {

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Authentication is required"));
        }

        Booking requested = new Booking();
        requested.setSlotId(slotId);
        requested.setEntryDate(entryDate);
        requested.setEntryTime(entryTime);
        requested.setExitDate(exitDate);
        requested.setExitTime(exitTime);

        Optional<String> intervalError =
                bookingAvailabilityService.validateInterval(requested);

        if (intervalError.isPresent()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "available", false,
                    "message", intervalError.get()));
        }

        Optional<ParkingSlot> slotOptional =
                parkingSlotRepository.findBySlotIdIgnoreCase(slotId.trim());

        if (slotOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "available", false,
                    "message", "Parking slot not found"));
        }

        requested.setSlotId(slotOptional.get().getSlotId());

        Optional<BookingAvailabilityService.Conflict> conflict =
                bookingAvailabilityService.findConflict(requested);

        if (conflict.isPresent()) {
            Booking existing = conflict.get().getExistingBooking();
            return ResponseEntity.ok(Map.of(
                    "available", false,
                    "message", buildConflictMessage(existing),
                    "conflictingBookingId", String.valueOf(existing.getBookingId())));
        }

        return ResponseEntity.ok(Map.of(
                "available", true,
                "message", "Slot is available for the selected time"));
    }

    @PostMapping
    public ResponseEntity<?> addBooking(
            @RequestBody Booking booking,
            Authentication authentication) {

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Authentication is required"));
        }

        if (booking.getBookingId() == null || booking.getBookingId().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Booking ID is required"));
        }

        if (bookingRepository.existsByBookingId(booking.getBookingId().trim())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "A booking with this booking ID already exists"));
        }

        String authenticatedEmail = authentication.getName();
        if (authenticatedEmail == null || authenticatedEmail.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "message", "Authenticated user email is missing"));
        }

        if (booking.getSlotId() == null || booking.getSlotId().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Parking slot is required"));
        }

        Optional<String> intervalError =
                bookingAvailabilityService.validateInterval(booking);
        if (intervalError.isPresent()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", intervalError.get()));
        }

        Optional<ParkingSlot> slotOptional =
                parkingSlotRepository.findBySlotIdIgnoreCase(booking.getSlotId().trim());

        if (slotOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "message", "Parking slot not found"));
        }

        ParkingSlot parkingSlot = slotOptional.get();
        String normalizedSlotId = parkingSlot.getSlotId();
        booking.setSlotId(normalizedSlotId);
        booking.setBookingId(booking.getBookingId().trim());

        // Never trust userName/userEmail supplied by the client.
        booking.setUserEmail(authenticatedEmail);

        Optional<User> userOptional = userRepository.findByEmail(authenticatedEmail);
        userOptional.ifPresent(user -> booking.setUserName(user.getName()));

        Object lock = slotLocks.computeIfAbsent(
                normalizedSlotId.trim().toLowerCase(),
                ignored -> new Object());

        synchronized (lock) {
            // Re-check inside the lock immediately before saving. This is
            // important because another request may have arrived after the
            // first check above.
            if (bookingRepository.existsByBookingId(booking.getBookingId())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                        "message", "A booking with this booking ID already exists"));
            }

            Optional<BookingAvailabilityService.Conflict> conflict =
                    bookingAvailabilityService.findConflict(booking);

            if (conflict.isPresent()) {
                Booking existing = conflict.get().getExistingBooking();

                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                        "message", buildConflictMessage(existing),
                        "code", "BOOKING_TIME_CONFLICT",
                        "slotId", booking.getSlotId(),
                        "conflictingBookingId", String.valueOf(existing.getBookingId()),
                        "minimumGapMinutes", BookingAvailabilityService.MINIMUM_GAP_MINUTES));
            }

            try {
                Booking savedBooking = bookingRepository.save(booking);
                return ResponseEntity.status(HttpStatus.CREATED).body(savedBooking);
            } catch (DuplicateKeyException ex) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                        "message", "A booking with this booking ID already exists"));
            }
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteBooking(
            @PathVariable String id,
            Authentication authentication) {

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Optional<Booking> bookingOptional = bookingRepository.findById(id);

        if (bookingOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Booking booking = bookingOptional.get();

        if (!isAdmin(authentication) && !isOwner(booking, authentication)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        bookingRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/booking/{bookingId}")
    public ResponseEntity<?> deleteBookingByBookingId(
            @PathVariable String bookingId,
            Authentication authentication) {

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Optional<Booking> bookingOptional =
                bookingRepository.findByBookingId(bookingId);

        if (bookingOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Booking booking = bookingOptional.get();

        if (!isAdmin(authentication) && !isOwner(booking, authentication)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        bookingRepository.delete(booking);
        return ResponseEntity.noContent().build();
    }

    private boolean isAdmin(Authentication authentication) {
        return authentication.getAuthorities().stream()
                .anyMatch(authority ->
                        "ROLE_ADMIN".equalsIgnoreCase(authority.getAuthority()));
    }

    private boolean isOwner(Booking booking, Authentication authentication) {
        String bookingEmail = booking.getUserEmail();
        String authenticatedEmail = authentication.getName();

        return bookingEmail != null
                && authenticatedEmail != null
                && bookingEmail.equalsIgnoreCase(authenticatedEmail);
    }

    private String buildConflictMessage(Booking existingBooking) {
        String slotId = existingBooking.getSlotId() == null
                ? "this slot"
                : existingBooking.getSlotId();

        String entry = String.valueOf(existingBooking.getEntryTime());
        String exit = String.valueOf(existingBooking.getExitTime());
        String date = String.valueOf(existingBooking.getEntryDate());

        return "Slot " + slotId
                + " is unavailable for the selected time. "
                + "There must be at least "
                + BookingAvailabilityService.MINIMUM_GAP_MINUTES
                + " minutes between bookings. Existing booking: "
                + date + " " + entry + "-" + exit + ".";
    }
}

package com.gagan.smartparking.controller;

import com.gagan.smartparking.model.Booking;
import com.gagan.smartparking.model.User;
import com.gagan.smartparking.repository.BookingRepository;
import com.gagan.smartparking.repository.UserRepository;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*")
public class BookingController {

    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    public BookingController(
            BookingRepository bookingRepository,
            UserRepository userRepository) {
        this.bookingRepository = bookingRepository;
        this.userRepository = userRepository;
    }

    @GetMapping
    public ResponseEntity<List<Booking>> getAllBookings() {
        return ResponseEntity.ok(bookingRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> addBooking(
            @RequestBody Booking booking,
            Authentication authentication) {

        if (booking.getBookingId() == null || booking.getBookingId().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "Booking ID is required"));
        }

        if (bookingRepository.existsByBookingId(booking.getBookingId())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                    "message", "A booking with this booking ID already exists"));
        }

        String authenticatedEmail = authentication == null
                ? null
                : authentication.getName();

        if (authenticatedEmail != null && !authenticatedEmail.isBlank()) {
            booking.setUserEmail(authenticatedEmail);

            Optional<User> userOptional = userRepository.findByEmail(authenticatedEmail);
            userOptional.ifPresent(user -> booking.setUserName(user.getName()));
        }

        Booking savedBooking = bookingRepository.save(booking);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedBooking);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBooking(@PathVariable String id) {
        Optional<Booking> booking = bookingRepository.findById(id);

        if (booking.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        bookingRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/booking/{bookingId}")
    public ResponseEntity<Void> deleteBookingByBookingId(
            @PathVariable String bookingId) {

        Optional<Booking> booking = bookingRepository.findByBookingId(bookingId);

        if (booking.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        bookingRepository.delete(booking.get());
        return ResponseEntity.noContent().build();
    }
}

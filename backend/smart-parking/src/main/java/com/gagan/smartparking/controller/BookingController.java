package com.gagan.smartparking.controller;

import com.gagan.smartparking.model.Booking;
import com.gagan.smartparking.repository.BookingRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*")
public class BookingController {

    private final BookingRepository bookingRepository;

    public BookingController(BookingRepository bookingRepository) {
        this.bookingRepository = bookingRepository;
    }

    @GetMapping
    public ResponseEntity<List<Booking>> getAllBookings() {
        return ResponseEntity.ok(bookingRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Booking> addBooking(
            @RequestBody Booking booking) {

        Booking savedBooking = bookingRepository.save(booking);

        return ResponseEntity.ok(savedBooking);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBooking(
            @PathVariable String id) {

        Optional<Booking> booking =
                bookingRepository.findById(id);

        if (booking.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        bookingRepository.deleteById(id);

        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/booking/{bookingId}")
    public ResponseEntity<Void> deleteBookingByBookingId(
            @PathVariable String bookingId) {

        Optional<Booking> booking =
                bookingRepository.findByBookingId(bookingId);

        if (booking.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        bookingRepository.delete(booking.get());

        return ResponseEntity.noContent().build();
    }
}
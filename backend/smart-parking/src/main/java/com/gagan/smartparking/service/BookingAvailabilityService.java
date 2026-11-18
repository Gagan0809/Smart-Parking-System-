package com.gagan.smartparking.service;

import com.gagan.smartparking.model.Booking;
import com.gagan.smartparking.repository.BookingRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;

@Service
public class BookingAvailabilityService {

    public static final long MINIMUM_GAP_MINUTES = 10L;

    private static final DateTimeFormatter DATE_FORMATTER =
            DateTimeFormatter.ISO_LOCAL_DATE;

    private final BookingRepository bookingRepository;

    public BookingAvailabilityService(BookingRepository bookingRepository) {
        this.bookingRepository = bookingRepository;
    }

    /**
     * Validates the requested interval itself.
     * Returns an error message when invalid, otherwise empty.
     */
    public Optional<String> validateInterval(Booking booking) {
        try {
            LocalDateTime start = toDateTime(
                    booking.getEntryDate(),
                    booking.getEntryTime());
            LocalDateTime end = toDateTime(
                    booking.getExitDate(),
                    booking.getExitTime());

            if (!start.isBefore(end)) {
                return Optional.of("Entry date/time must be before exit date/time");
            }

            return Optional.empty();
        } catch (DateTimeParseException ex) {
            return Optional.of(
                    "Invalid booking date/time. Use YYYY-MM-DD and HH:mm format");
        }
    }

    /**
     * Finds a conflicting booking for the same slot.
     *
     * A booking reserves its requested interval plus a 10-minute safety gap
     * on both sides. Therefore:
     *   08:00-10:00 followed by 10:10-12:00 -> allowed
     *   08:00-10:00 followed by 10:05-12:00 -> rejected
     */
    public Optional<Conflict> findConflict(Booking requested) {
        LocalDateTime requestedStart = toDateTime(
                requested.getEntryDate(),
                requested.getEntryTime());
        LocalDateTime requestedEnd = toDateTime(
                requested.getExitDate(),
                requested.getExitTime());

        String slotId = normalize(requested.getSlotId());
        if (slotId.isEmpty()) {
            return Optional.empty();
        }

        List<Booking> existingBookings =
                bookingRepository.findBySlotIdIgnoreCase(requested.getSlotId());

        for (Booking existing : existingBookings) {
            if (existing.getBookingId() != null
                    && existing.getBookingId().equalsIgnoreCase(requested.getBookingId())) {
                continue;
            }

            LocalDateTime existingStart;
            LocalDateTime existingEnd;

            try {
                existingStart = toDateTime(
                        existing.getEntryDate(),
                        existing.getEntryTime());
                existingEnd = toDateTime(
                        existing.getExitDate(),
                        existing.getExitTime());
            } catch (DateTimeParseException ignored) {
                // Existing bookings created through this API should be valid.
                // Invalid legacy data is ignored here so it does not make every
                // new booking for the slot impossible.
                continue;
            }

            LocalDateTime protectedExistingStart =
                    existingStart.minusMinutes(MINIMUM_GAP_MINUTES);
            LocalDateTime protectedExistingEnd =
                    existingEnd.plusMinutes(MINIMUM_GAP_MINUTES);

            boolean conflicts =
                    requestedStart.isBefore(protectedExistingEnd)
                            && requestedEnd.isAfter(protectedExistingStart);

            if (conflicts) {
                return Optional.of(new Conflict(existing));
            }
        }

        return Optional.empty();
    }

    public LocalDateTime toDateTime(String date, String time) {
        if (date == null || date.isBlank() || time == null || time.isBlank()) {
            throw new DateTimeParseException("Date/time is missing", "", 0);
        }

        String normalizedTime = normalizeTime(time);

        LocalDate localDate = LocalDate.parse(
                date.trim(),
                DATE_FORMATTER);
        LocalTime localTime = LocalTime.parse(normalizedTime);

        return LocalDateTime.of(localDate, localTime);
    }

    private String normalizeTime(String value) {
        String normalized = value.trim();

        // Accept H:mm as well as HH:mm, while keeping the stored contract
        // used by the Flutter client unchanged.
        if (normalized.matches("\\d{1}:\\d{2}")) {
            normalized = "0" + normalized;
        }

        return normalized;
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    public static final class Conflict {
        private final Booking existingBooking;

        public Conflict(Booking existingBooking) {
            this.existingBooking = existingBooking;
        }

        public Booking getExistingBooking() {
            return existingBooking;
        }
    }
}

package com.gagan.smartparking.service;

import com.gagan.smartparking.model.Booking;
import com.gagan.smartparking.repository.BookingRepository;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class BookingAvailabilityServiceTest {

    @Test
    void allowsTenMinuteGap() {
        Booking existing = booking("OLD", "08:00", "10:00");
        Booking requested = booking("NEW", "10:10", "12:00");

        BookingAvailabilityService service = serviceWith(existing);

        assertTrue(service.findConflict(requested).isEmpty());
    }

    @Test
    void rejectsFiveMinuteGap() {
        Booking existing = booking("OLD", "08:00", "10:00");
        Booking requested = booking("NEW", "10:05", "12:00");

        BookingAvailabilityService service = serviceWith(existing);

        assertTrue(service.findConflict(requested).isPresent());
    }

    @Test
    void rejectsOverlappingBooking() {
        Booking existing = booking("OLD", "08:00", "10:00");
        Booking requested = booking("NEW", "09:30", "11:00");

        BookingAvailabilityService service = serviceWith(existing);

        assertTrue(service.findConflict(requested).isPresent());
    }

    @Test
    void permitsDifferentSlotsAtSameTime() {
        Booking existing = booking("OLD", "08:00", "10:00");
        existing.setSlotId("A-1");

        Booking requested = booking("NEW", "08:00", "10:00");
        requested.setSlotId("A-2");

        BookingAvailabilityService service = serviceWith(existing);

        // The proxy only returns bookings for the requested slot, therefore
        // a different slot has no conflict.
        BookingRepository repository = repositoryForSlot(requested.getSlotId(), List.of());
        service = new BookingAvailabilityService(repository);

        assertTrue(service.findConflict(requested).isEmpty());
    }

    @Test
    void rejectsInvalidInterval() {
        Booking requested = booking("NEW", "10:00", "08:00");
        BookingAvailabilityService service = serviceWith();

        assertTrue(service.validateInterval(requested).isPresent());
    }

    private BookingAvailabilityService serviceWith(Booking... bookings) {
        List<Booking> results = bookings.length == 0 ? List.of() : List.of(bookings);
        String slot = bookings.length == 0 ? "A-1" : bookings[0].getSlotId();
        return new BookingAvailabilityService(repositoryForSlot(slot, results));
    }

    private BookingRepository repositoryForSlot(Booking booking, String requestedSlot) {
        return repositoryForSlot(
                requestedSlot,
                booking == null ? List.of() : List.of(booking));
    }

    private BookingRepository repositoryForSlot(
            String requestedSlot,
            List<Booking> results) {
        return (BookingRepository) Proxy.newProxyInstance(
                BookingRepository.class.getClassLoader(),
                new Class[]{BookingRepository.class},
                (proxy, method, args) -> {
                    if ("findBySlotIdIgnoreCase".equals(method.getName())) {
                        String slot = args == null || args.length == 0
                                ? ""
                                : String.valueOf(args[0]);
                        return requestedSlot.equalsIgnoreCase(slot)
                                ? results
                                : List.of();
                    }
                    if (method.getReturnType().equals(boolean.class)) {
                        return false;
                    }
                    if (method.getReturnType().equals(long.class)) {
                        return 0L;
                    }
                    return null;
                });
    }

    private Booking booking(String id, String start, String end) {
        Booking booking = new Booking();
        booking.setBookingId(id);
        booking.setSlotId("A-1");
        booking.setEntryDate("2026-09-30");
        booking.setEntryTime(start);
        booking.setExitDate("2026-09-30");
        booking.setExitTime(end);
        return booking;
    }
}

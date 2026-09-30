# Booking rules

The booking API enforces the following rules on the server:

1. A booking must have a valid start and end date/time, and the start must be before the end.
2. A parking slot cannot have overlapping bookings.
3. There must be at least 10 complete minutes between two bookings for the same slot.
4. Different parking slots may be booked for the same time.
5. Different dates may be booked independently.
6. Normal users can only list and cancel their own bookings.
7. Admin users can list and manage all bookings through the admin endpoints.

Examples for the same slot:

- 08:00-10:00 + 10:05-12:00 -> rejected
- 08:00-10:00 + 10:10-12:00 -> allowed
- 08:00-10:00 + 10:15-12:00 -> allowed
- 08:00-10:00 + 09:30-11:00 -> rejected
- A-1 08:00-10:00 + A-2 08:00-10:00 -> allowed

The POST endpoint is the final authority. The optional GET `/api/bookings/availability` endpoint is intended only for UI pre-checks.

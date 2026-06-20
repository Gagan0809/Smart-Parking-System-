import 'package:flutter/material.dart';
import '../models/parking_slot.dart';
import '../models/booking.dart';
import '../models/search_criteria.dart';

class ParkingController extends ChangeNotifier {
  final List<ParkingSlot> _slots = ParkingSlot.seed();
  final List<Booking> _bookings = [];

  String _userName = 'Guest';
  int _bookingNumber = 2401;

  List<ParkingSlot> get slots => _slots;
  List<Booking> get bookings => _bookings;
  String get userName => _userName;

  void handleAuthentication(String name) {
    _userName = name.trim().isEmpty ? 'Guest' : name;
    notifyListeners();
  }

  Booking bookSlot({
    required ParkingSlot slot,
    required SearchCriteria criteria,
    required String timeRange,
  }) {
    final booking = Booking(
      id: 'BK-${_bookingNumber++}',
      slotId: slot.id,
      location: criteria.location,
      entryDate: criteria.entryDate,
      entryTime: criteria.entryTime,
      exitDate: criteria.exitDate,
      exitTime: criteria.exitTime,
      timeRange: timeRange,
    );

    slot.isOccupied = true;
    _bookings.add(booking);
    notifyListeners();
    return booking;
  }

  void cancelBooking(String bookingId) {
    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex == -1) return;

    final booking = _bookings.removeAt(bookingIndex);
    final slotIndex = _slots.indexWhere((s) => s.id == booking.slotId);
    if (slotIndex != -1) {
      _slots[slotIndex].isOccupied = false;
    }
    notifyListeners();
  }

  void resetDemoData() {
    _slots.clear();
    _slots.addAll(ParkingSlot.seed());
    _bookings.clear();
    notifyListeners();
  }

  void logout() {
    _userName = 'Guest';
    notifyListeners();
  }
}

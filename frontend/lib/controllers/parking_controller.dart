import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../models/parking_slot.dart';
import '../models/search_criteria.dart';

class ParkingController extends ChangeNotifier {
  final List<ParkingSlot> _slots = ParkingSlot.seed();
  final List<Booking> _bookings = [];

  String _userName = 'Guest';
  int _bookingNumber = 2401;
  bool _isAdmin = false;

  final String _baseUrl = 'http://192.168.1.7:8080';

  List<ParkingSlot> get slots => _slots;
  List<Booking> get bookings => _bookings;

  String get userName => _userName;
  String get currentUserName => _userName;

  bool get isAdmin => _isAdmin;

  Future<void> loadParkingSlots() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/parking-slots'),
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      final loadedSlots = data.map((item) {
        final slot = item as Map<String, dynamic>;

        final status =
            slot['status']?.toString().toLowerCase() ?? 'available';

        final List<String> timeSlots =
            (slot['timeSlots'] as List<dynamic>?)
                ?.map((time) => time.toString())
                .toList() ??
                [
                  '08:00 - 10:00',
                  '12:00 - 14:00',
                  '16:00 - 18:00',
                ];

        return ParkingSlot(
          id: slot['slotId']?.toString() ?? '',
          location: slot['location']?.toString() ?? '',
          isOccupied: status == 'occupied',
          timeSlots: timeSlots,
          backendId: slot['id']?.toString(),
        );
      }).toList();

      _slots
        ..clear()
        ..addAll(loadedSlots);

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addParkingSlot({
    required String slotId,
    required String location,
    required String status,
    required List<String> timeSlots,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/parking-slots'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'slotId': slotId,
          'location': location,
          'status': status,
          'timeSlots': timeSlots,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      await loadParkingSlots();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateParkingSlot({
    required String backendId,
    required String slotId,
    required String location,
    required String status,
    required List<String> timeSlots,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/parking-slots/$backendId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'slotId': slotId,
          'location': location,
          'status': status,
          'timeSlots': timeSlots,
        }),
      );

      if (response.statusCode != 200) {
        return false;
      }

      await loadParkingSlots();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteParkingSlot(String backendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/parking-slots/$backendId'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        return false;
      }

      await loadParkingSlots();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/bookings'),
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      final loadedBookings = data.map((item) {
        final booking = item as Map<String, dynamic>;

        return Booking(
          id: booking['bookingId']?.toString() ?? '',
          slotId: booking['slotId']?.toString() ?? '',
          location: booking['location']?.toString() ?? '',
          entryDate: DateTime.parse(
            booking['entryDate']?.toString() ?? DateTime.now().toIso8601String(),
          ),
          entryTime: _parseTimeOfDay(
            booking['entryTime']?.toString() ?? '00:00',
          ),
          exitDate: DateTime.parse(
            booking['exitDate']?.toString() ?? DateTime.now().toIso8601String(),
          ),
          exitTime: _parseTimeOfDay(
            booking['exitTime']?.toString() ?? '00:00',
          ),
          timeRange: booking['timeRange']?.toString() ?? '',
        );
      }).toList();

      _bookings
        ..clear()
        ..addAll(loadedBookings);

      for (final booking in _bookings) {
        final slotIndex = _slots.indexWhere(
              (slot) => slot.id == booking.slotId,
        );

        if (slotIndex != -1) {
          _slots[slotIndex].isOccupied = true;
        }
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> _saveBooking(Booking booking) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': booking.id,
          'slotId': booking.slotId,
          'location': booking.location,
          'entryDate': _formatDate(booking.entryDate),
          'entryTime': _formatTimeOfDay(booking.entryTime),
          'exitDate': _formatDate(booking.exitDate),
          'exitTime': _formatTimeOfDay(booking.exitTime),
          'timeRange': booking.timeRange,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
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

    unawaited(_saveBooking(booking));

    return booking;
  }

  Future<bool> cancelBooking(String bookingId) async {
    final bookingIndex = _bookings.indexWhere(
          (booking) => booking.id == bookingId,
    );

    if (bookingIndex == -1) {
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/bookings/booking/$bookingId'),
      );

      if (response.statusCode != 204 &&
          response.statusCode != 200 &&
          response.statusCode != 404) {
        return false;
      }
    } catch (_) {
      return false;
    }

    final booking = _bookings.removeAt(bookingIndex);

    final slotIndex = _slots.indexWhere(
          (slot) => slot.id == booking.slotId,
    );

    if (slotIndex != -1) {
      _slots[slotIndex].isOccupied = false;
    }

    notifyListeners();

    return true;
  }

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      Map<String, dynamic>? data;

      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          data = null;
        }
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        _userName = name.trim().isEmpty ? 'Guest' : name.trim();
        _isAdmin = false;

        notifyListeners();

        return null;
      }

      return data?['message']?.toString() ??
          data?['error']?.toString() ??
          'Registration failed';
    } catch (e) {
      return 'Unable to connect to the server: $e';
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      Map<String, dynamic>? data;

      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          data = null;
        }
      }

      if (response.statusCode == 200) {
        final user = data?['user'] as Map<String, dynamic>?;

        _userName = user?['name']?.toString() ??
            data?['name']?.toString() ??
            email.split('@').first;

        _isAdmin = false;

        notifyListeners();

        return null;
      }

      return data?['message']?.toString() ??
          data?['error']?.toString() ??
          'Login failed';
    } catch (e) {
      return 'Unable to connect to the server: $e';
    }
  }

  void handleAuthentication(String name) {
    _userName = name.trim().isEmpty ? 'Guest' : name.trim();
    _isAdmin = false;

    notifyListeners();
  }

  bool handleAdminAuthentication(
      String email,
      String password,
      ) {
    const adminEmail = 'admin@smartparking.com';
    const adminPassword = 'admin123';

    if (email.trim().toLowerCase() == adminEmail &&
        password == adminPassword) {
      _isAdmin = true;
      _userName = 'Admin';

      notifyListeners();

      return true;
    }

    _isAdmin = false;

    notifyListeners();

    return false;
  }

  void resetDemoData() {
    _slots
      ..clear()
      ..addAll(ParkingSlot.seed());

    _bookings.clear();

    _bookingNumber = 2401;

    notifyListeners();
  }

  void logout() {
    _userName = 'Guest';
    _isAdmin = false;

    notifyListeners();
  }

  void adminLogout() {
    _userName = 'Guest';
    _isAdmin = false;

    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}
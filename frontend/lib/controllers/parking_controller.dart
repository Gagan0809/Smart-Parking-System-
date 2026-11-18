
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/parking_location.dart';
import '../models/parking_slot.dart';
import '../models/search_criteria.dart';

class BookingAvailabilityResult {
  const BookingAvailabilityResult({
    required this.available,
    required this.message,
    this.error = false,
  });

  final bool available;
  final String message;
  final bool error;
}

class BookingCreationResult {
  const BookingCreationResult({
    required this.success,
    required this.message,
    this.booking,
    this.conflict = false,
  });

  final bool success;
  final String message;
  final Booking? booking;
  final bool conflict;
}

class ParkingController extends ChangeNotifier {
  final List<ParkingSlot> _slots = ParkingSlot.seed();
  final List<Booking> _bookings = [];
  final List<ParkingLocation> _parkingLocations = [];
  final List<Map<String, dynamic>> _adminUsers = [];
  final Map<String, String> _adminBookingsBackendIds = {};

  String _userName = 'Guest';
  String? _userEmail;
  int _bookingNumber = 2401;
  bool _isAdmin = false;
  String? _token;

  WebSocket? _parkingWebSocket;
  Timer? _realtimeReconnectTimer;
  Timer? _realtimeFallbackTimer;
  DateTime? _lastRealtimeMessageAt;
  bool _realtimeShouldReconnect = true;
  bool _realtimeConnecting = false;
  bool _realtimeConnected = false;

  final String _baseUrl =
      'https://smart-parking-system-9mbk.onrender.com';

  List<ParkingSlot> get slots => _slots;
  List<Booking> get bookings => _bookings;
  List<ParkingLocation> get parkingLocations =>
      List.unmodifiable(_parkingLocations);
  List<Map<String, dynamic>> get adminUsers =>
      List.unmodifiable(_adminUsers);
  Map<String, String> get adminBookingsBackendIds =>
      Map.unmodifiable(_adminBookingsBackendIds);

  String get userName => _userName;
  String get currentUserName => _userName;
  String? get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isRealtimeConnected => _realtimeConnected;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('jwt_token');

    final savedUserName = prefs.getString('user_name');
    final savedEmail = prefs.getString('user_email');
    final savedRole = prefs.getString('user_role');

    if (savedUserName != null && savedUserName.isNotEmpty) {
      _userName = savedUserName;
    }

    _userEmail = savedEmail;

    _isAdmin = savedRole?.toUpperCase() == 'ADMIN';

    notifyListeners();
  }

  Future<void> _saveAuthentication({
    required String token,
    required String userName,
    required String role,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('jwt_token', token);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_role', role);
    if (userEmail != null && userEmail.isNotEmpty) {
      await prefs.setString('user_email', userEmail);
    } else {
      await prefs.remove('user_email');
    }

    _token = token;
    _userName = userName;
    _userEmail = userEmail;
    _isAdmin = role.toUpperCase() == 'ADMIN';
  }

  Future<void> _clearAuthentication() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await prefs.remove('user_email');

    _token = null;
    _userName = 'Guest';
    _userEmail = null;
    _isAdmin = false;
  }

  Future<Map<String, String>> _authHeaders() async {
    if (_token == null || _token!.isEmpty) {
      await loadToken();
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<void> initializeRealtime() async {
    await loadParkingSlots();
    await connectRealtime();
    _startRealtimeFallbackSync();
  }

  void _startRealtimeFallbackSync() {
    _realtimeFallbackTimer?.cancel();

    _realtimeFallbackTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!_realtimeShouldReconnect || !isLoggedIn) {
          return;
        }

        final lastMessage = _lastRealtimeMessageAt;
        final hasRecentMessage = lastMessage != null &&
            DateTime.now().difference(lastMessage).inSeconds < 2;

        if (!hasRecentMessage) {
          unawaited(_syncParkingSlotsFromServer());
        }
      },
    );
  }

  Future<void> _syncParkingSlotsFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/parking-slots'),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);
      bool changed = false;

      for (final item in data) {
        if (item is! Map) {
          continue;
        }

        final slotData = Map<String, dynamic>.from(item);
        final slotId = slotData['slotId']?.toString().trim();
        if (slotId == null || slotId.isEmpty) {
          continue;
        }

        final status =
            slotData['status']?.toString().trim().toLowerCase() ??
                'available';

        final occupied = status == 'occupied' ||
            status == 'reserved' ||
            status == 'maintenance';

        final index = _slots.indexWhere(
          (slot) => slot.id.toLowerCase() == slotId.toLowerCase(),
        );

        if (index == -1) {
          _slots.add(
            ParkingSlot(
              id: slotId,
              location: slotData['location']?.toString() ?? '',
              isOccupied: occupied,
              timeSlots: (slotData['timeSlots'] as List?)
                      ?.map((item) => item.toString())
                      .toList() ??
                  const [],
              backendId: slotData['id']?.toString(),
              price: _parseDouble(slotData['price'], 20.0),
              latitude: _parseNullableDouble(slotData['latitude']),
              longitude: _parseNullableDouble(slotData['longitude']),
            ),
          );
          changed = true;
        } else if (_slots[index].isOccupied != occupied) {
          _slots[index].isOccupied = occupied;
          changed = true;
        }
      }

      if (changed) {
        notifyListeners();
      }
    } catch (_) {
      // Keep the last known state if the fallback request fails.
    }
  }

  Future<void> connectRealtime() async {
    _realtimeShouldReconnect = true;

    if (_realtimeConnecting || _realtimeConnected) {
      return;
    }

    _realtimeConnecting = true;
    _realtimeReconnectTimer?.cancel();

    try {
      final websocketUrl = _baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      final socket = await WebSocket.connect(
        '$websocketUrl/ws/parking',
      ).timeout(const Duration(seconds: 15));

      if (!_realtimeShouldReconnect) {
        await socket.close();
        return;
      }

      socket.pingInterval = const Duration(seconds: 20);
      _parkingWebSocket = socket;
      _realtimeConnected = true;
      _realtimeConnecting = false;
      _lastRealtimeMessageAt = DateTime.now();
      debugPrint('[Realtime] WebSocket connected.');
      notifyListeners();

      socket.listen(
        _handleRealtimeMessage,
        onError: (_) {
          _realtimeConnected = false;
          _realtimeConnecting = false;
          notifyListeners();
          _scheduleRealtimeReconnect();
        },
        onDone: () {
          _parkingWebSocket = null;
          _realtimeConnected = false;
          _realtimeConnecting = false;
          notifyListeners();
          _scheduleRealtimeReconnect();
        },
        cancelOnError: false,
      );
    } catch (error) {
      _realtimeConnected = false;
      _realtimeConnecting = false;
      debugPrint('[Realtime] WebSocket connection failed: $error');
      notifyListeners();
      _scheduleRealtimeReconnect();
    }
  }

  void _scheduleRealtimeReconnect() {
    if (!_realtimeShouldReconnect || _realtimeReconnectTimer?.isActive == true) {
      return;
    }

    _realtimeReconnectTimer = Timer(
      const Duration(seconds: 5),
      () {
        unawaited(connectRealtime());
      },
    );
  }

  void _handleRealtimeMessage(dynamic message) {
    _lastRealtimeMessageAt = DateTime.now();

    if (message is! String || message.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final type = decoded['type']?.toString();
      debugPrint('[Realtime] Message received. type=$type');
      if (type != 'parking_update') {
        return;
      }

      final rawSlots = decoded['slots'];
      if (rawSlots is! List) {
        return;
      }

      for (final rawSlot in rawSlots) {
        if (rawSlot is! Map) {
          continue;
        }

        final slotId = rawSlot['slotId']?.toString();
        if (slotId == null || slotId.isEmpty) {
          continue;
        }

        final status = rawSlot['status']?.toString().toLowerCase() ?? 'available';
        final occupied = rawSlot['occupied'] == true ||
            rawSlot['reserved'] == true ||
            status == 'occupied' ||
            status == 'reserved' ||
            status == 'maintenance';

        final index = _slots.indexWhere(
          (slot) => slot.id.toLowerCase() == slotId.toLowerCase(),
        );

        if (index == -1) {
          _slots.add(
            ParkingSlot(
              id: slotId,
              location: rawSlot['location']?.toString() ?? '',
              isOccupied: occupied,
              timeSlots: (rawSlot['timeSlots'] as List?)
                      ?.map((item) => item.toString())
                      .toList() ??
                  const [],
              backendId: rawSlot['id']?.toString(),
              price: _parseDouble(rawSlot['price'], 20.0),
              latitude: _parseNullableDouble(rawSlot['latitude']),
              longitude: _parseNullableDouble(rawSlot['longitude']),
            ),
          );
        } else {
          _slots[index].isOccupied = occupied;
        }
      }

      notifyListeners();

      // Reconcile the local state with the authoritative REST representation.
      // This also handles cases where a reserved slot and physical occupancy
      // are represented differently by the backend.
      unawaited(loadParkingSlots());
    } catch (error) {
      debugPrint('[Realtime] Invalid WebSocket message: $error');
    }
  }

  Future<void> loadParkingSlots() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/parking-slots'),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      final loadedSlots = data.map((item) {
        final slot = item as Map<String, dynamic>;

        final status =
            slot['status']?.toString().toLowerCase() ?? 'available';

        final reserved = slot['reserved'] == true || status == 'reserved';
        final unavailable = status == 'occupied' ||
            status == 'reserved' ||
            status == 'maintenance' ||
            reserved;

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
          isOccupied: unavailable,
          timeSlots: timeSlots,
          backendId: slot['id']?.toString(),
          price: _parseDouble(slot['price'], 20.0),
          latitude: _parseNullableDouble(slot['latitude']),
          longitude: _parseNullableDouble(slot['longitude']),
        );
      }).toList();

      _slots
        ..clear()
        ..addAll(loadedSlots);

      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadParkingLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/parking-locations'),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      final loadedLocations = data
          .map(
            (item) => ParkingLocation.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      _parkingLocations
        ..clear()
        ..addAll(loadedLocations);

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addParkingLocation({
    required String name,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/parking-locations'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'name': name,
          'address': address,
          'slots': 0,
          'status': 'Active',
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        return false;
      }

      await loadParkingLocations();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateParkingLocation({
    required String backendId,
    required String name,
    required String address,
    required int slots,
    required String status,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/admin/parking-locations/$backendId'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'name': name,
          'address': address,
          'slots': slots,
          'status': status,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        return false;
      }

      await loadParkingLocations();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteParkingLocation(String backendId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$_baseUrl/api/admin/parking-locations/$backendId',
        ),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 204 &&
          response.statusCode != 200) {
        return false;
      }

      await loadParkingLocations();

      return true;
    } catch (_) {
      return false;
    }
  }

  double _parseDouble(dynamic value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double? _parseNullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(value?.toString() ?? '');

    return parsed;
  }

  List<ParkingSlot> searchParking({
    String query = '',
    double? userLatitude,
    double? userLongitude,
    double? maxDistanceKm,
    double? maxPrice,
    bool availableOnly = false,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return _slots.where((slot) {
      if (availableOnly && slot.isOccupied) {
        return false;
      }

      if (normalizedQuery.isNotEmpty) {
        final matchesLocation =
            slot.location.toLowerCase().contains(normalizedQuery);

        final matchesSlotId =
            slot.id.toLowerCase().contains(normalizedQuery);

        if (!matchesLocation && !matchesSlotId) {
          return false;
        }
      }

      if (maxPrice != null && slot.price > maxPrice) {
        return false;
      }

      if (maxDistanceKm != null) {
        if (userLatitude == null ||
            userLongitude == null ||
            slot.latitude == null ||
            slot.longitude == null) {
          return false;
        }

        final distance = calculateDistanceKm(
          userLatitude,
          userLongitude,
          slot.latitude!,
          slot.longitude!,
        );

        if (distance > maxDistanceKm) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  double? distanceFrom(
    ParkingSlot slot, {
    required double userLatitude,
    required double userLongitude,
  }) {
    if (slot.latitude == null || slot.longitude == null) {
      return null;
    }

    return calculateDistanceKm(
      userLatitude,
      userLongitude,
      slot.latitude!,
      slot.longitude!,
    );
  }

  double calculateDistanceKm(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadiusKm = 6371.0;

    final latitudeDifference =
        _degreesToRadians(latitude2 - latitude1);

    final longitudeDifference =
        _degreesToRadians(longitude2 - longitude1);

    final latitude1Radians =
        _degreesToRadians(latitude1);

    final latitude2Radians =
        _degreesToRadians(latitude2);

    final a =
        sin(latitudeDifference / 2) *
            sin(latitudeDifference / 2) +
        cos(latitude1Radians) *
            cos(latitude2Radians) *
            sin(longitudeDifference / 2) *
            sin(longitudeDifference / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  List<ParkingSlot> filterByLocation(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List<ParkingSlot>.from(_slots);
    }

    return _slots.where((slot) {
      return slot.location
          .toLowerCase()
          .contains(normalizedQuery);
    }).toList();
  }

  List<ParkingSlot> filterByPrice(double maxPrice) {
    return _slots.where((slot) {
      return slot.price <= maxPrice;
    }).toList();
  }

  List<ParkingSlot> filterByDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
  }) {
    return _slots.where((slot) {
      if (slot.latitude == null || slot.longitude == null) {
        return false;
      }

      final distance = calculateDistanceKm(
        userLatitude,
        userLongitude,
        slot.latitude!,
        slot.longitude!,
      );

      return distance <= maxDistanceKm;
    }).toList();
  }

  Future<bool> addParkingSlot({
    required String slotId,
    required String location,
    required String status,
    required List<String> timeSlots,
    double price = 20.0,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/parking-slots'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'slotId': slotId,
          'location': location,
          'status': status,
          'price': price,
          'latitude': latitude,
          'longitude': longitude,
          'timeSlots': timeSlots,
        }),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
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
    double price = 20.0,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$_baseUrl/api/admin/parking-slots/$backendId',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({
          'slotId': slotId,
          'location': location,
          'status': status,
          'price': price,
          'latitude': latitude,
          'longitude': longitude,
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
        Uri.parse(
          '$_baseUrl/api/admin/parking-slots/$backendId',
        ),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 204 &&
          response.statusCode != 200) {
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
        headers: await _authHeaders(),
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
          entryDate: DateTime.tryParse(booking['entryDate']?.toString() ?? '') ?? DateTime.now(),
          entryTime: _parseTimeOfDay(booking['entryTime']?.toString() ?? '00:00'),
          exitDate: DateTime.tryParse(booking['exitDate']?.toString() ?? '') ?? DateTime.now(),
          exitTime: _parseTimeOfDay(booking['exitTime']?.toString() ?? '00:00'),
          timeRange: booking['timeRange']?.toString() ?? '',
          userName: booking['userName']?.toString(),
          userEmail: booking['userEmail']?.toString(),
        );
      }).toList();

      _bookings
        ..clear()
        ..addAll(loadedBookings);

      // Reservations are time-specific. Physical occupancy remains controlled
      // by realtime IoT state.
      notifyListeners();
    } catch (_) {}
  }

  Future<BookingAvailabilityResult> checkBookingAvailability({
    required ParkingSlot slot,
    required SearchCriteria criteria,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/bookings/availability').replace(
        queryParameters: {
          'slotId': slot.id,
          'entryDate': _formatDate(criteria.entryDate),
          'entryTime': _formatTimeOfDay(criteria.entryTime),
          'exitDate': _formatDate(criteria.exitDate),
          'exitTime': _formatTimeOfDay(criteria.exitTime),
        },
      );

      final response = await http.get(uri, headers: await _authHeaders());

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        final available = data?['available'] == true;
        return BookingAvailabilityResult(
          available: available,
          message: data?['message']?.toString() ??
              (available
                  ? 'Slot is available for the selected time.'
                  : 'Slot is already booked for the selected time.'),
        );
      }

      return BookingAvailabilityResult(
        available: false,
        message: data?['message']?.toString() ??
            'Unable to check slot availability right now.',
        error: true,
      );
    } catch (_) {
      return const BookingAvailabilityResult(
        available: false,
        message: 'Unable to check slot availability. Please try again.',
        error: true,
      );
    }
  }

  Future<BookingCreationResult> bookSlot({
    required ParkingSlot slot,
    required SearchCriteria criteria,
    required String timeRange,
  }) async {
    final booking = Booking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch}-${_bookingNumber++}',
      slotId: slot.id,
      location: criteria.location.isNotEmpty ? criteria.location : slot.location,
      entryDate: criteria.entryDate,
      entryTime: criteria.entryTime,
      exitDate: criteria.exitDate,
      exitTime: criteria.exitTime,
      timeRange: timeRange,
      userName: _userName,
      userEmail: _userEmail,
    );

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/bookings'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'bookingId': booking.id,
          'slotId': booking.slotId,
          'location': booking.location,
          'entryDate': _formatDate(booking.entryDate),
          'entryTime': _formatTimeOfDay(booking.entryTime),
          'exitDate': _formatDate(booking.exitDate),
          'exitTime': _formatTimeOfDay(booking.exitTime),
          'timeRange': booking.timeRange,
          'userName': booking.userName,
          'userEmail': booking.userEmail,
        }),
      );

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final saved = data == null
            ? booking
            : Booking(
                id: data['bookingId']?.toString() ?? booking.id,
                slotId: data['slotId']?.toString() ?? booking.slotId,
                location: data['location']?.toString() ?? booking.location,
                entryDate: DateTime.tryParse(data['entryDate']?.toString() ?? '') ?? booking.entryDate,
                entryTime: _parseTimeOfDay(data['entryTime']?.toString() ?? _formatTimeOfDay(booking.entryTime)),
                exitDate: DateTime.tryParse(data['exitDate']?.toString() ?? '') ?? booking.exitDate,
                exitTime: _parseTimeOfDay(data['exitTime']?.toString() ?? _formatTimeOfDay(booking.exitTime)),
                timeRange: data['timeRange']?.toString() ?? booking.timeRange,
                userName: data['userName']?.toString() ?? booking.userName,
                userEmail: data['userEmail']?.toString() ?? booking.userEmail,
              );

        _bookings.add(saved);
        notifyListeners();

        return BookingCreationResult(
          success: true,
          message: 'Booking confirmed.',
          booking: saved,
        );
      }

      return BookingCreationResult(
        success: false,
        message: data?['message']?.toString() ?? 'Booking could not be created.',
        conflict: response.statusCode == 409,
      );
    } catch (_) {
      return const BookingCreationResult(
        success: false,
        message: 'Unable to connect to the booking server.',
      );
    }
  }

  Future<void> loadAdminUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/users'),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      _adminUsers
        ..clear()
        ..addAll(
          data.map(
            (item) => Map<String, dynamic>.from(item as Map),
          ),
        );

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> deleteAdminUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/admin/users/$userId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        return false;
      }

      await loadAdminUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadAdminBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/bookings'),
        headers: await _authHeaders(),
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
          entryDate: DateTime.tryParse(
                booking['entryDate']?.toString() ?? '',
              ) ??
              DateTime.now(),
          entryTime: _parseTimeOfDay(
            booking['entryTime']?.toString() ?? '00:00',
          ),
          exitDate: DateTime.tryParse(
                booking['exitDate']?.toString() ?? '',
              ) ??
              DateTime.now(),
          exitTime: _parseTimeOfDay(
            booking['exitTime']?.toString() ?? '00:00',
          ),
          timeRange: booking['timeRange']?.toString() ?? '',
          userName: booking['userName']?.toString(),
          userEmail: booking['userEmail']?.toString(),
        );
      }).toList();

      _bookings
        ..clear()
        ..addAll(loadedBookings);

      _adminBookingsBackendIds
        ..clear()
        ..addEntries(
          data.map((item) {
            final booking = item as Map<String, dynamic>;
            final bookingId = booking['bookingId']?.toString() ?? '';
            final backendId = booking['id']?.toString() ?? '';
            return MapEntry(bookingId, backendId);
          }),
        );

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> cancelAdminBooking(String backendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/admin/bookings/$backendId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        return false;
      }

      await loadAdminBookings();
      return true;
    } catch (_) {
      return false;
    }
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
        Uri.parse(
          '$_baseUrl/api/bookings/booking/$bookingId',
        ),
        headers: await _authHeaders(),
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

  Future<String?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/login'),
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
        final token = data?['token']?.toString();
        final user = data?['user'] as Map<String, dynamic>?;

        if (token == null || token.isEmpty) {
          return 'Login succeeded but no authentication token was returned';
        }

        final name = user?['name']?.toString() ?? 'Admin';
        final role = user?['role']?.toString() ?? 'ADMIN';
        final userEmail = user?['email']?.toString() ?? email;

        await _saveAuthentication(
          token: token,
          userName: name,
          role: role,
          userEmail: userEmail,
        );

        notifyListeners();
        unawaited(initializeRealtime());

        return null;
      }

      return data?['message']?.toString() ?? 'Admin login failed';
    } catch (e) {
      return 'Unable to connect to the server: $e';
    }
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
          data = jsonDecode(response.body)
              as Map<String, dynamic>;
        } catch (_) {
          data = null;
        }
      }

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        _userName =
            name.trim().isEmpty ? 'Guest' : name.trim();
        _userEmail = email.trim();

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
          data = jsonDecode(response.body)
              as Map<String, dynamic>;
        } catch (_) {
          data = null;
        }
      }

      if (response.statusCode == 200) {
        final token = data?['token']?.toString();
        final user =
            data?['user'] as Map<String, dynamic>?;

        if (token == null || token.isEmpty) {
          return 'Login succeeded but no authentication token was returned';
        }

        final name =
            user?['name']?.toString() ??
            data?['name']?.toString() ??
            email.split('@').first;

        final role =
            user?['role']?.toString() ??
            data?['role']?.toString() ??
            'USER';

        await _saveAuthentication(
          token: token,
          userName: name,
          role: role,
          userEmail: email.trim(),
        );

        notifyListeners();
        unawaited(initializeRealtime());

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
    _userName =
        name.trim().isEmpty ? 'Guest' : name.trim();

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

  Future<void> logout() async {
    await disconnectRealtime();
    await _clearAuthentication();

    notifyListeners();
  }

  Future<void> adminLogout() async {
    await disconnectRealtime();
    await _clearAuthentication();

    notifyListeners();
  }

  Future<void> disconnectRealtime() async {
    _realtimeShouldReconnect = false;
    _realtimeReconnectTimer?.cancel();
    _realtimeReconnectTimer = null;
    _realtimeFallbackTimer?.cancel();
    _realtimeFallbackTimer = null;
    _realtimeConnecting = false;
    _realtimeConnected = false;

    final socket = _parkingWebSocket;
    _parkingWebSocket = null;

    if (socket != null) {
      try {
        await socket.close(WebSocketStatus.goingAway);
      } catch (_) {
        // Socket may already be closed.
      }
    }
  }

  @override
  void dispose() {
    unawaited(disconnectRealtime());
    super.dispose();
  }

  void resetDemoData() {
    _slots
      ..clear()
      ..addAll(ParkingSlot.seed());

    _bookings.clear();
    _parkingLocations.clear();
    _adminUsers.clear();
    _adminBookingsBackendIds.clear();

    _bookingNumber = 2401;

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


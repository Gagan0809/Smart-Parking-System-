import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../models/search_criteria.dart';
import '../widgets/navigation/parking_bottom_nav.dart';
import '../widgets/parking/search_panel.dart';
import '../widgets/parking/parking_map.dart';
import 'available_slots_page.dart';
import 'bookings_page.dart';
import 'menu_page.dart';

class NearestParkingPage extends StatefulWidget {
  const NearestParkingPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<NearestParkingPage> createState() => _NearestParkingPageState();
}

class _NearestParkingPageState extends State<NearestParkingPage> {
  final _locationController = TextEditingController();
  final _locationFocusNode = FocusNode();

  DateTime? _entryDate;
  DateTime? _exitDate;
  double _mapZoom = 1;

  static const backgroundColor = Color(0xFFF5F6FA);
  static const primaryBlue = Color(0xFF3269B3);
  static const darkText = Color(0xFF303B4A);
  static const secondaryText = Color(0xFF748093);
  static const lightBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    _locationController.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    _locationController.removeListener(_onLocationChanged);
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.controller.currentUserName.isEmpty
        ? 'Driver'
        : widget.controller.currentUserName;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'WELCOME BACK',
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        color: darkText,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: lightBlue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: primaryBlue,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Find your\nparking spot',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Search for available parking spaces near you.',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SearchPanel(
                            locationController: _locationController,
                            locationFocusNode: _locationFocusNode,
                            entryDate: _entryDate,
                            exitDate: _exitDate,
                            onPickEntryDate: () {
                              _pickDate(isEntry: true);
                            },
                            onPickExitDate: () {
                              _pickDate(isEntry: false);
                            },
                            onSearch: _searchParking,
                            onClear: _clearForm,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Parking around you',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              _locationController.text.trim().isEmpty
                                  ? 'Nearby'
                                  : _locationController.text.trim(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * 0.38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ParkingMap(
                                  zoom: _mapZoom,
                                  location: _locationController.text.trim(),
                                  onZoomIn: () {
                                    setState(() {
                                      _mapZoom = (_mapZoom + 0.1)
                                          .clamp(0.8, 1.5)
                                          .toDouble();
                                    });
                                  },
                                  onZoomOut: () {
                                    setState(() {
                                      _mapZoom = (_mapZoom - 0.1)
                                          .clamp(0.8, 1.5)
                                          .toDouble();
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                top: 14,
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_parking_rounded,
                                        size: 17,
                                        color: primaryBlue,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Available parking',
                                        style: TextStyle(
                                          color: darkText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ParkingBottomNav(
                selectedIndex: 0,
                bookingCount: widget.controller.bookings.length,
                onHome: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You are already on Home'),
                    ),
                  );
                },
                onBookings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingsPage(
                        controller: widget.controller,
                      ),
                    ),
                  );
                },
                onMenu: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MenuPage(
                        controller: widget.controller,
                      ),
                    ),
                  );
                },
                onSearch: () {
                  _locationFocusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required bool isEntry,
  }) async {
    final today = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: isEntry
          ? (_entryDate ?? today)
          : (_exitDate ?? _entryDate ?? today),
      firstDate: today,
      lastDate: today.add(
        const Duration(days: 365),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      if (isEntry) {
        _entryDate = selected;

        if (_exitDate != null && _exitDate!.isBefore(selected)) {
          _exitDate = selected;
        }
      } else {
        _exitDate = selected;
      }
    });
  }

  void _searchParking() {
    final location = _locationController.text.trim();

    if (location.isEmpty) {
      _locationFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
        ),
      );

      return;
    }

    final today = DateTime.now();

    final entryDate = _entryDate ??
        DateTime(
          today.year,
          today.month,
          today.day,
        );

    final exitDate = _exitDate ?? entryDate;

    final criteria = SearchCriteria(
      location: location,
      entryDate: entryDate,
      entryTime: const TimeOfDay(
        hour: 8,
        minute: 0,
      ),
      exitDate: exitDate,
      exitTime: const TimeOfDay(
        hour: 10,
        minute: 0,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvailableSlotsPage(
          criteria: criteria,
          controller: widget.controller,
        ),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _locationController.clear();
      _entryDate = null;
      _exitDate = null;
      _mapZoom = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search cleared'),
      ),
    );
  }
}
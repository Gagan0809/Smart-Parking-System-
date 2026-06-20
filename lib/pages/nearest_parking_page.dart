import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../controllers/parking_controller.dart';
import '../models/search_criteria.dart';
import '../widgets/navigation/parking_bottom_nav.dart';
import '../widgets/parking/search_panel.dart';
import '../widgets/parking/parking_map.dart';
import 'available_slots_page.dart';
import 'bookings_page.dart';
import 'menu_page.dart';

class NearestParkingPage extends StatefulWidget {
  const NearestParkingPage({required this.controller, super.key});

  final ParkingController controller;

  @override
  State<NearestParkingPage> createState() => _NearestParkingPageState();
}

class _NearestParkingPageState extends State<NearestParkingPage> {
  final _locationController = TextEditingController();
  final _locationFocusNode = FocusNode();

  DateTime? _entryDate;
  DateTime? _exitDate;
  TimeOfDay? _entryTime;
  TimeOfDay? _exitTime;
  double _mapZoom = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    _locationController.addListener(_onLocationChanged);
  }

  void _onLocationChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    _locationController.removeListener(_onLocationChanged);
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _onStateChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                      child: Column(
                        children: [
                          const Text(
                            'Nearest Parking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SearchPanel(
                            locationController: _locationController,
                            locationFocusNode: _locationFocusNode,
                            entryDate: _entryDate,
                            entryTime: _entryTime,
                            exitDate: _exitDate,
                            exitTime: _exitTime,
                            onPickEntryDate: () => _pickDate(isEntry: true),
                            onPickEntryTime: () => _pickTime(isEntry: true),
                            onPickExitDate: () => _pickDate(isEntry: false),
                            onPickExitTime: () => _pickTime(isEntry: false),
                            onSearch: _searchParking,
                            onClear: _clearForm,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.38,
                      child: ParkingMap(
                        zoom: _mapZoom,
                        location: _locationController.text.trim(),
                        onZoomIn: () {
                          setState(() {
                            _mapZoom = (_mapZoom + 0.1).clamp(0.8, 1.5).toDouble();
                          });
                        },
                        onZoomOut: () {
                          setState(() {
                            _mapZoom = (_mapZoom - 0.1).clamp(0.8, 1.5).toDouble();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ParkingBottomNav(
              selectedIndex: 0,
              bookingCount: widget.controller.bookings.length,
              onHome: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You are already on Home')),
                );
              },
              onBookings: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookingsPage(controller: widget.controller)),
              ),
              onMenu: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MenuPage(controller: widget.controller)),
              ),
              onSearch: () {
                _locationFocusNode.requestFocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a location to search')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isEntry}) async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: isEntry
          ? (_entryDate ?? today)
          : (_exitDate ?? _entryDate ?? today),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (!mounted || selected == null) return;

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

  Future<void> _pickTime({required bool isEntry}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isEntry
          ? (_entryTime ?? TimeOfDay.now())
          : (_exitTime ?? _defaultExitTime(_entryTime ?? TimeOfDay.now())),
    );

    if (!mounted || selected == null) return;

    setState(() {
      if (isEntry) {
        _entryTime = selected;
        _exitTime ??= _defaultExitTime(selected);
      } else {
        _exitTime = selected;
      }
    });
  }

  void _searchParking() {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      _locationFocusNode.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }

    final today = DateTime.now();
    final entryDate = _entryDate ?? DateTime(today.year, today.month, today.day);
    final entryTime = _entryTime ?? TimeOfDay.now();
    final exitDate = _exitDate ?? entryDate;
    final exitTime = _exitTime ?? _defaultExitTime(entryTime);

    if (_isInvalidRange(entryDate, entryTime, exitDate, exitTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exit must be after entry')),
      );
      return;
    }

    final criteria = SearchCriteria(
      location: location,
      entryDate: entryDate,
      entryTime: entryTime,
      exitDate: exitDate,
      exitTime: exitTime,
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

  bool _isInvalidRange(DateTime entryDate, TimeOfDay entryTime, DateTime exitDate, TimeOfDay exitTime) {
    final entry = DateTime(entryDate.year, entryDate.month, entryDate.day, entryTime.hour, entryTime.minute);
    final exit = DateTime(exitDate.year, exitDate.month, exitDate.day, exitTime.hour, exitTime.minute);
    return !exit.isAfter(entry);
  }

  TimeOfDay _defaultExitTime(TimeOfDay entryTime) {
    final totalMinutes = (entryTime.hour * 60 + entryTime.minute + 120) % 1440;
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  void _clearForm() {
    setState(() {
      _locationController.clear();
      _entryDate = null;
      _exitDate = null;
      _entryTime = null;
      _exitTime = null;
      _mapZoom = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search cleared')));
  }
}

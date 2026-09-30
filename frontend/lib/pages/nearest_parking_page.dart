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



  double? _maxDistanceKm;
  double? _maxPrice;
  bool _availableOnly = false;

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

    widget.controller.loadParkingSlots();
    widget.controller.loadBookings();
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

  int get _activeFilterCount {
    int count = 0;

    if (_maxDistanceKm != null) {
      count++;
    }

    if (_maxPrice != null) {
      count++;
    }

    if (_availableOnly) {
      count++;
    }

    return count;
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
                physics: const ClampingScrollPhysics(),
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                          const SizedBox(height: 14),
                          _buildFilterButton(),
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
                                child: Listener(
                                  behavior: HitTestBehavior.opaque,
                                  child: ParkingMap(
                                    location: _locationController.text.trim(),
                                    controller: widget.controller,
                                    maxDistanceKm: _maxDistanceKm,
                                    maxPrice: _maxPrice,
                                    availableOnly: _availableOnly,
                                  ),
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

  Widget _buildFilterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _showFilters,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFDCE2EA),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.tune_rounded,
              color: primaryBlue,
              size: 21,
            ),
            const SizedBox(width: 9),
            const Text(
              'Filters',
              style: TextStyle(
                color: darkText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (_activeFilterCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 23,
                height: 23,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_activeFilterCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showFilters() async {
    double? selectedDistance = _maxDistanceKm;
    double? selectedPrice = _maxPrice;
    bool selectedAvailableOnly = _availableOnly;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5DAE2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Filter parking',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose the parking options you want to see.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Maximum distance',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _distanceChoice(
                          label: '1 km',
                          value: 1,
                          selected: selectedDistance == 1,
                          onTap: () {
                            setSheetState(() {
                              selectedDistance = 1;
                            });
                          },
                        ),
                        _distanceChoice(
                          label: '2 km',
                          value: 2,
                          selected: selectedDistance == 2,
                          onTap: () {
                            setSheetState(() {
                              selectedDistance = 2;
                            });
                          },
                        ),
                        _distanceChoice(
                          label: '5 km',
                          value: 5,
                          selected: selectedDistance == 5,
                          onTap: () {
                            setSheetState(() {
                              selectedDistance = 5;
                            });
                          },
                        ),
                        _distanceChoice(
                          label: '10 km',
                          value: 10,
                          selected: selectedDistance == 10,
                          onTap: () {
                            setSheetState(() {
                              selectedDistance = 10;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Maximum price',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _priceChoice(
                          label: '₹20',
                          value: 20,
                          selected: selectedPrice == 20,
                          onTap: () {
                            setSheetState(() {
                              selectedPrice = 20;
                            });
                          },
                        ),
                        _priceChoice(
                          label: '₹40',
                          value: 40,
                          selected: selectedPrice == 40,
                          onTap: () {
                            setSheetState(() {
                              selectedPrice = 40;
                            });
                          },
                        ),
                        _priceChoice(
                          label: '₹60',
                          value: 60,
                          selected: selectedPrice == 60,
                          onTap: () {
                            setSheetState(() {
                              selectedPrice = 60;
                            });
                          },
                        ),
                        _priceChoice(
                          label: '₹100',
                          value: 100,
                          selected: selectedPrice == 100,
                          onTap: () {
                            setSheetState(() {
                              selectedPrice = 100;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        value: selectedAvailableOnly,
                        onChanged: (value) {
                          setSheetState(() {
                            selectedAvailableOnly = value;
                          });
                        },
                        activeThumbColor: primaryBlue,
                        title: const Text(
                          'Available parking only',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: const Text(
                          'Hide occupied parking slots',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _maxDistanceKm = null;
                                _maxPrice = null;
                                _availableOnly = false;
                              });

                              Navigator.of(sheetContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(
                                color: Color(0xFFDCE2EA),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: darkText,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _maxDistanceKm = selectedDistance;
                                _maxPrice = selectedPrice;
                                _availableOnly =
                                    selectedAvailableOnly;
                              });

                              Navigator.of(sheetContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Apply filters',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _distanceChoice({
    required String label,
    required double value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _filterChoice(
      label: label,
      selected: selected,
      onTap: onTap,
    );
  }

  Widget _priceChoice({
    required String label,
    required double value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _filterChoice(
      label: label,
      selected: selected,
      onTap: onTap,
    );
  }

  Widget _filterChoice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue
              : const Color(0xFFF6F8FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primaryBlue
                : const Color(0xFFE0E5EC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : darkText,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
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

        if (_exitDate != null &&
            _exitDate!.isBefore(selected)) {
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
      maxDistanceKm: _maxDistanceKm,
      maxPrice: _maxPrice,
      availableOnly: _availableOnly,
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
      _maxDistanceKm = null;
      _maxPrice = null;
      _availableOnly = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search cleared'),
      ),
    );
  }
}
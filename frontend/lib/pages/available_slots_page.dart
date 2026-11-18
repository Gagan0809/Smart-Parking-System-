import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../controllers/parking_controller.dart';
import '../models/parking_slot.dart';
import '../models/search_criteria.dart';
import 'slot_details_page.dart';

class AvailableSlotsPage extends StatefulWidget {
  const AvailableSlotsPage({
    required this.criteria,
    required this.controller,
    super.key,
  });

  final SearchCriteria criteria;
  final ParkingController controller;

  @override
  State<AvailableSlotsPage> createState() => _AvailableSlotsPageState();
}

class _AvailableSlotsPageState extends State<AvailableSlotsPage> {
  ParkingSlot? _selectedSlot;
  Position? _currentPosition;
  String? _checkingSlotId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    widget.controller.loadParkingSlots();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    if (widget.criteria.maxDistanceKm == null) {
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = position;
      });
    } catch (_) {}
  }

  Future<void> _selectSlot(ParkingSlot slot) async {
    if (slot.isOccupied || _checkingSlotId != null) {
      return;
    }

    setState(() {
      _checkingSlotId = slot.id;
      _selectedSlot = null;
    });

    final result = await widget.controller.checkBookingAvailability(
      slot: slot,
      criteria: widget.criteria,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _checkingSlotId = null;
    });

    if (!result.available) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            result.error ? 'Availability Check Failed' : 'Slot Already Booked',
            style: const TextStyle(
              color: Color(0xFF303B4A),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            result.message,
            style: const TextStyle(
              color: Color(0xFF748093),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3269B3),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(result.error ? 'Try Again' : 'Choose Another Time'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _selectedSlot = slot;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    final selected = _selectedSlot;

    if (selected != null) {
    final matchingSlots = widget.controller.slots.where(
    (slot) => slot.id == selected.id,
    );

    if (matchingSlots.isEmpty || matchingSlots.first.isOccupied) {
    _selectedSlot = null;
    }
    }

    setState(() {});

  }

  List<ParkingSlot> _filteredSlots() {
    return widget.controller.searchParking(
      query: widget.criteria.location,
      userLatitude: _currentPosition?.latitude,
      userLongitude: _currentPosition?.longitude,
      maxDistanceKm: widget.criteria.maxDistanceKm,
      maxPrice: widget.criteria.maxPrice,
      availableOnly: widget.criteria.availableOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = _filteredSlots();

    return Scaffold(
    backgroundColor: const Color(0xFFF4F6FA),
    body: SafeArea(
    child: Column(
    children: [
    _header(),
    _searchSummary(),
    Expanded(
    child: slots.isEmpty
    ? _emptyState()
        : ListView.separated(
    padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
    itemCount: slots.length,
    separatorBuilder: (context, index) =>
    const SizedBox(height: 14),
    itemBuilder: (context, index) {
    final slot = slots[index];
    final selected = _selectedSlot?.id == slot.id;

    return _slotCard(
    slot: slot,
    selected: selected,
    );
    },
    ),
    ),
    _bottomButton(),
    ],
    ),
    ),
    );

  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E9F0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF263445),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Available Slots',
              style: TextStyle(
                color: Color(0xFF263445),
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEF6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_parking,
              color: Color(0xFF1064CD),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(28, 18, 28, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF146FE6),
            Color(0xFF146FE6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFFE4ECF8),
                size: 25,
              ),
              SizedBox(width: 12),
              Text(
                'PARKING LOCATION',
                style: TextStyle(
                  color: Color(0xFFD5E1F2),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 37),
            child: Text(
              widget.criteria.location,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(
              color: Color(0x55FFFFFF),
              height: 1,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _dateInfo(
                  icon: Icons.login,
                  label: 'ENTRY',
                  value:
                  '${widget.criteria.entryDate.day.toString().padLeft(2, '0')}/${widget.criteria.entryDate.month.toString().padLeft(2, '0')}/${widget.criteria.entryDate.year}',
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _dateInfo(
                  icon: Icons.logout,
                  label: 'EXIT',
                  value:
                  '${widget.criteria.exitDate.day.toString().padLeft(2, '0')}/${widget.criteria.exitDate.month.toString().padLeft(2, '0')}/${widget.criteria.exitDate.year}',
                ),
              ),
            ],
          ),
          if (widget.criteria.maxPrice != null ||
              widget.criteria.maxDistanceKm != null ||
              widget.criteria.availableOnly) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(
                color: Color(0x55FFFFFF),
                height: 1,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.criteria.maxPrice != null)
                  _filterBadge(
                    Icons.currency_rupee,
                    'Up to ₹${widget.criteria.maxPrice!.toStringAsFixed(0)}',
                  ),
                if (widget.criteria.maxDistanceKm != null)
                  _filterBadge(
                    Icons.near_me,
                    'Within ${widget.criteria.maxDistanceKm!.toStringAsFixed(0)} km',
                  ),
                if (widget.criteria.availableOnly)
                  _filterBadge(
                    Icons.check_circle_outline,
                    'Available only',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x44FFFFFF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFD5E1F2),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD5E1F2),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _slotCard({
    required ParkingSlot slot,
    required bool selected,
  }) {
    final occupied = slot.isOccupied;

    return Material(
    color: Colors.transparent,
    child: InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: occupied || _checkingSlotId != null
        ? null
        : () => _selectSlot(slot),
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: occupied
    ? const Color(0xFFF1F3F6)
        : Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
    color: selected
    ? const Color(0xFF146FE6)
        : occupied
    ? const Color(0xFFD9DEE6)
        : const Color(0xFFE4E8EF),
    width: selected ? 2 : 1,
    ),
    boxShadow: const [
    BoxShadow(
    color: Color(0x12000000),
    blurRadius: 18,
    offset: Offset(0, 7),
    ),
    ],
    ),
    child: Row(
    children: [
    Container(
    width: 62,
    height: 62,
    decoration: BoxDecoration(
    color: occupied
    ? const Color(0xFFE0E3E8)
        : selected
    ? const Color(0xFF146FE6)
        : const Color(0xFFE8EEF7),
    borderRadius: BorderRadius.circular(18),
    ),
    child: Icon(
    Icons.local_parking,
    color: occupied
    ? const Color(0xFF8A96A6)
        : selected
    ? Colors.white
        : const Color(0xFF146FE6),
    size: 34,
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Slot ${slot.id}',
    style: TextStyle(
    color: occupied
    ? const Color(0xFF697586)
        : const Color(0xFF2B3748),
    fontSize: 19,
    fontWeight: FontWeight.w800,
    ),
    ),
    const SizedBox(height: 7),
    Text(
    occupied
        ? 'Occupied'
        : _checkingSlotId == slot.id
            ? 'Checking availability...'
            : 'Available',
    style: TextStyle(
    color: occupied
    ? const Color(0xFFB54747)
        : const Color(0xFF24834D),
    fontSize: 15,
    fontWeight: FontWeight.w700,
    ),
    ),
    const SizedBox(height: 5),
    Text(
    '₹${slot.price.toStringAsFixed(0)}',
    style: TextStyle(
    color: occupied
    ? const Color(0xFF8A96A6)
        : const Color(0xFF146FE6),
    fontSize: 14,
    fontWeight: FontWeight.w700,
    ),
    ),
    ],
    ),
    ),
    const SizedBox(width: 10),
    if (!occupied)
    AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: 28,
    height: 28,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: selected
    ? const Color(0xFF146FE6)
        : Colors.transparent,
    border: Border.all(
    color: selected
    ? const Color(0xFF146FE6)
        : const Color(0xFFB7C1CE),
    width: 2,
    ),
    ),
    child: selected
    ? const Icon(
    Icons.check,
    color: Colors.white,
    size: 19,
    )
        : null,
    )
    else
    Container(
    width: 28,
    height: 28,
    decoration: const BoxDecoration(
    shape: BoxShape.circle,
    color: Color(0xFFE0E3E8),
    ),
    child: const Icon(
    Icons.block,
    color: Color(0xFF8A96A6),
    size: 17,
    ),
    ),
    ],
    ),
    ),
    ),
    );

  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_parking_outlined,
              color: Color(0xFF8A96A6),
              size: 70,
            ),
            const SizedBox(height: 18),
            const Text(
              'No parking slots found',
              style: TextStyle(
                color: Color(0xFF2B3748),
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters
                  ? 'No slots match your selected filters.'
                  : 'No parking slots have been added yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasActiveFilters {
    return widget.criteria.maxDistanceKm != null ||
        widget.criteria.maxPrice != null ||
        widget.criteria.availableOnly ||
        widget.criteria.location.trim().isNotEmpty;
  }

  Widget _bottomButton() {
    final hasSelection = _selectedSlot != null;

    return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(28, 14, 28, 22),
    decoration: const BoxDecoration(
    color: Color(0xFFF4F6FA),
    border: Border(
    top: BorderSide(
    color: Color(0xFFE2E6EC),
    ),
    ),
    ),
    child: SizedBox(
    height: 62,
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: hasSelection
    ? const Color(0xFF2E63A7)
        : const Color(0xFFD5DBE4),
    foregroundColor: hasSelection
    ? Colors.white
        : const Color(0xFF7A8593),
    elevation: 0,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
    ),
    ),
    onPressed: hasSelection ? _continueToDetails : null,
    child: Text(
    hasSelection
    ? 'Continue with Slot ${_selectedSlot!.id}'
        : 'Select a Parking Slot',
    style: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    ),
    ),
    ),
    ),
    );

  }

  void _continueToDetails() {
    if (_selectedSlot == null || _selectedSlot!.isOccupied) {
      return;
    }

    Navigator.of(context).push(
    MaterialPageRoute(
    builder: (context) => SlotDetailsPage(
    slot: _selectedSlot!,
    criteria: widget.criteria,
    controller: widget.controller,
    ),
    ),
    );

  }
}

import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../controllers/parking_controller.dart';
import '../models/parking_slot.dart';
import '../models/search_criteria.dart';
import '../widgets/parking/search_summary.dart';
import '../widgets/parking/selected_slot_card.dart';
import '../widgets/parking/slot_list_tile.dart';
import 'bookings_page.dart';

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
  String? _selectedSlotId;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _selectFirstAvailable();
    widget.controller.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 24, 14),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Available Slots',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: SearchSummary(criteria: widget.criteria),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemBuilder: (context, index) {
                  final slot = widget.controller.slots[index];
                  final isSelected = slot.id == _selectedSlotId && slot.isAvailable;
                  if (isSelected) {
                    return SelectedSlotCard(
                      slot: slot,
                      selectedTimeSlot: _selectedTimeSlot,
                      onSelectTime: (timeSlot) => setState(() => _selectedTimeSlot = timeSlot),
                      onBook: () => _bookSelectedSlot(slot),
                    );
                  }

                  return SlotListTile(
                    slot: slot,
                    onTap: () {
                      if (slot.isOccupied) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Slot ${slot.id} is occupied')),
                        );
                        return;
                      }
                      setState(() {
                        _selectedSlotId = slot.id;
                        _selectedTimeSlot = slot.timeSlots.first;
                      });
                    },
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemCount: widget.controller.slots.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFirstAvailable() {
    final availableSlots = widget.controller.slots.where((slot) => slot.isAvailable);
    if (availableSlots.isEmpty) {
      _selectedSlotId = null;
      _selectedTimeSlot = null;
      return;
    }
    final slot = availableSlots.first;
    _selectedSlotId = slot.id;
    _selectedTimeSlot = slot.timeSlots.first;
  }

  Future<void> _bookSelectedSlot(ParkingSlot slot) async {
    final selectedTimeSlot = _selectedTimeSlot;
    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a time slot')));
      return;
    }

    final booking = widget.controller.bookSlot(
      slot: slot,
      criteria: widget.criteria,
      timeRange: selectedTimeSlot,
    );

    _selectFirstAvailable();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Booking Confirmed'),
          content: Text('${booking.id} is reserved for Slot ${booking.slotId}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => BookingsPage(controller: widget.controller)),
                );
              },
              child: const Text('View Bookings'),
            ),
          ],
        );
      },
    );
  }
}

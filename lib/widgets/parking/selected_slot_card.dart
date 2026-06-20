import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/parking_slot.dart';
import '../common/action_button.dart';
import 'slot_status_badge.dart';
import 'time_slot_button.dart';

class SelectedSlotCard extends StatelessWidget {
  const SelectedSlotCard({
    required this.slot,
    required this.selectedTimeSlot,
    required this.onSelectTime,
    required this.onBook,
    super.key,
  });

  final ParkingSlot slot;
  final String? selectedTimeSlot;
  final ValueChanged<String> onSelectTime;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Slot ${slot.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SlotStatusBadge(isAvailable: true),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Time Slots:',
            style: TextStyle(
              color: Color(0xFFE0DFE8),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          ...slot.timeSlots.map(
            (timeSlot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TimeSlotButton(
                label: timeSlot,
                isSelected: timeSlot == selectedTimeSlot,
                onTap: () => onSelectTime(timeSlot),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ActionButton(
            label: 'Book Now',
            color: AppColors.brightBlue,
            foregroundColor: Colors.white,
            onPressed: onBook,
          ),
        ],
      ),
    );
  }
}

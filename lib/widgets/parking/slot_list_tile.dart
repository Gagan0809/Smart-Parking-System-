import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/parking_slot.dart';
import 'slot_status_badge.dart';

class SlotListTile extends StatelessWidget {
  const SlotListTile({
    required this.slot,
    required this.onTap,
    super.key,
  });

  final ParkingSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: slot.isAvailable ? AppColors.panel : AppColors.occupiedCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
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
              SlotStatusBadge(isAvailable: slot.isAvailable),
            ],
          ),
        ),
      ),
    );
  }
}

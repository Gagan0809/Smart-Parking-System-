import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SlotStatusBadge extends StatelessWidget {
  const SlotStatusBadge({required this.isAvailable, super.key});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 78),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.available : AppColors.occupied,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Occupied',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

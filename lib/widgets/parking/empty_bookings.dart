import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../common/action_button.dart';

class EmptyBookings extends StatelessWidget {
  const EmptyBookings({required this.onFindParking, super.key});

  final VoidCallback onFindParking;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_parking,
              color: Colors.white.withValues(alpha: 0.9),
              size: 54,
            ),
            const SizedBox(height: 18),
            const Text(
              'No bookings yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 20),
            ActionButton(
              label: 'Find Parking',
              color: AppColors.brightBlue,
              foregroundColor: Colors.white,
              onPressed: onFindParking,
            ),
          ],
        ),
      ),
    );
  }
}

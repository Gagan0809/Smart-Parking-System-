import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/booking.dart';
import '../common/action_button.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.booking,
    required this.onCancel,
    super.key,
  });

  final Booking booking;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                  'Slot ${booking.slotId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                booking.id,
                style: const TextStyle(
                  color: Color(0xFFE7E8F1),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BookingDetailRow(icon: Icons.place, label: booking.location),
          BookingDetailRow(icon: Icons.schedule, label: booking.timeRange),
          BookingDetailRow(
            icon: Icons.login,
            label:
                '${AppUtils.formatDate(booking.entryDate)} ${AppUtils.formatTimeOfDay(booking.entryTime)}',
          ),
          BookingDetailRow(
            icon: Icons.logout,
            label:
                '${AppUtils.formatDate(booking.exitDate)} ${AppUtils.formatTimeOfDay(booking.exitTime)}',
          ),
          const SizedBox(height: 14),
          ActionButton(
            label: 'Cancel Booking',
            color: AppColors.occupied,
            foregroundColor: Colors.white,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

class BookingDetailRow extends StatelessWidget {
  const BookingDetailRow({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.78), size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

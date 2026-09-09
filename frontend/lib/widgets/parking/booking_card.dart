import 'package:flutter/material.dart';
import '../../core/utils.dart';
import '../../models/booking.dart';

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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          Divider(
            color: Colors.grey.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 12),
          _detailRow(
            Icons.local_parking,
            'Slot',
            booking.slotId,
          ),
          _detailRow(
            Icons.location_on_outlined,
            'Parking Location',
            booking.location,
          ),
          _detailRow(
            Icons.calendar_today_outlined,
            'Entry Date',
            AppUtils.formatDate(booking.entryDate),
          ),
          _detailRow(
            Icons.calendar_today_outlined,
            'Exit Date',
            AppUtils.formatDate(booking.exitDate),
          ),
          _detailRow(
            Icons.login,
            'Entry Time',
            AppUtils.formatTimeOfDay(booking.entryTime),
          ),
          _detailRow(
            Icons.logout,
            'Exit Time',
            AppUtils.formatTimeOfDay(booking.exitTime),
            removeBottomPadding: true,
          ),
          const SizedBox(height: 16),
          Divider(
            color: Colors.grey.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52424),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Cancel Booking',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                color: Color(0xFF3269B3),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Parking Booking',
            style: TextStyle(
              color: Color(0xFF303B4A),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          booking.id,
          style: const TextStyle(
            color: Color(0xFF748093),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
      IconData icon,
      String label,
      String value, {
        bool removeBottomPadding = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: removeBottomPadding ? 0 : 16,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Icon(
              icon,
              color: const Color(0xFF3269B3),
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF748093),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF303B4A),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
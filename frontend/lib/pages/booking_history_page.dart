import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../models/booking.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  static const backgroundColor = Color(0xFFF5F6FA);
  static const primaryBlue = Color(0xFF3269B3);
  static const darkText = Color(0xFF303B4A);
  static const secondaryText = Color(0xFF748093);
  static const lightBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = widget.controller.bookings;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: bookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  28,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: bookings.length,
                separatorBuilder: (_, _) =>
                const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildHistoryCard(bookings[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: darkText,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Booking History',
              style: TextStyle(
                color: darkText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: primaryBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: primaryBlue,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Booking History',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your completed or previous bookings will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: primaryBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ${booking.id}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Parking Slot ${booking.slotId}',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: const Color(0xFFE8EBF0),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.confirmation_number_outlined,
            'Booking ID',
            booking.id,
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.local_parking_outlined,
            'Slot',
            booking.slotId,
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.location_on_outlined,
            'Location',
            booking.location,
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.access_time_rounded,
            'Time',
            booking.timeRange,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'History',
        style: TextStyle(
          color: primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            color: secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: darkText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
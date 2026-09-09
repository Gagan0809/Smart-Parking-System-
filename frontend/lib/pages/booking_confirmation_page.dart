import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/booking.dart';
import '../widgets/common/action_button.dart';
import 'bookings_page.dart';
import 'nearest_parking_page.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({
    required this.booking,
    required this.controller,
    required this.duration,
    required this.total,
    required this.paymentMethod,
    super.key,
  });

  final Booking booking;
  final ParkingController controller;
  final Duration duration;
  final double total;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 30),
                child: Column(
                  children: [
                    _successIcon(),
                    const SizedBox(height: 24),
                    const Text(
                      'Booking Confirmed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF354052),
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your parking slot has been successfully reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF748094),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _sectionHeader(
                      icon: Icons.local_parking,
                      title: 'Booking Details',
                      subtitle: 'Your reserved parking information',
                    ),
                    const SizedBox(height: 14),
                    _bookingCard(),
                    const SizedBox(height: 24),
                    _sectionHeader(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Details',
                      subtitle: 'Your payment information',
                    ),
                    const SizedBox(height: 14),
                    _paymentCard(),
                    const SizedBox(height: 26),
                    ActionButton(
                      label: 'View My Bookings',
                      color: const Color(0xFF2E65B0),
                      foregroundColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => BookingsPage(
                              controller: controller,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: 'Back to Home',
                      color: Colors.white,
                      foregroundColor: const Color(0xFF354052),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => NearestParkingPage(
                              controller: controller,
                            ),
                          ),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE1E4E9),
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
              color: Color(0xFF354052),
              size: 27,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Booking Confirmed',
              style: TextStyle(
                color: Color(0xFF354052),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE3E9F1),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              'P',
              style: TextStyle(
                color: Color(0xFF315B93),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEBE7),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Color(0xFF178C55),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF315B93),
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF354052),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF748094),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFE),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow(
            icon: Icons.receipt_long_outlined,
            label: 'Booking ID',
            value: booking.id,
          ),
          _divider(),
          _detailRow(
            icon: Icons.local_parking,
            label: 'Slot',
            value: booking.slotId,
          ),
          _divider(),
          _detailRow(
            icon: Icons.location_on_outlined,
            label: 'Parking Location',
            value: booking.location,
          ),
          _divider(),
          _detailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Entry Date',
            value: AppUtils.formatDate(booking.entryDate),
          ),
          _divider(),
          _detailRow(
            icon: Icons.event_outlined,
            label: 'Exit Date',
            value: AppUtils.formatDate(booking.exitDate),
          ),
          _divider(),
          _detailRow(
            icon: Icons.input,
            label: 'Entry Time',
            value: AppUtils.formatTimeOfDay(booking.entryTime),
          ),
          _divider(),
          _detailRow(
            icon: Icons.output,
            label: 'Exit Time',
            value: AppUtils.formatTimeOfDay(booking.exitTime),
          ),
          _divider(),
          _detailRow(
            icon: Icons.schedule_outlined,
            label: 'Duration',
            value: _formatDuration(duration),
            removeBottomPadding: true,
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFE),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Payment Method',
            value: paymentMethod,
          ),
          _divider(),
          _detailRow(
            icon: Icons.currency_rupee,
            label: 'Amount Paid',
            value: '₹${total.toStringAsFixed(0)}',
            bold: true,
          ),
          _divider(),
          _detailRow(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: 'Paid',
            valueColor: AppColors.available,
            bold: true,
            removeBottomPadding: true,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    bool bold = false,
    Color? valueColor,
    bool removeBottomPadding = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        bottom: removeBottomPadding ? 12 : 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Icon(
              icon,
              color: const Color(0xFF315B93),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6E7A8C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF354052),
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE4E7EC),
    );
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }
}
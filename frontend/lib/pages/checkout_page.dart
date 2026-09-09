import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../core/utils.dart';
import '../models/parking_slot.dart';
import '../models/search_criteria.dart';
import '../widgets/common/action_button.dart';
import 'booking_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    required this.slot,
    required this.criteria,
    required this.controller,
    required this.duration,
    required this.total,
    super.key,
  });

  final ParkingSlot slot;
  final SearchCriteria criteria;
  final ParkingController controller;
  final Duration duration;
  final double total;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'UPI';

  double get serviceFee => 5;

  double get finalTotal => widget.total + serviceFee;

  static const Color _background = Color(0xFFF3F5FA);
  static const Color _primaryText = Color(0xFF303B4B);
  static const Color _secondaryText = Color(0xFF778397);
  static const Color _blue = Color(0xFF2E67B1);
  static const Color _card = Colors.white;
  static const Color _iconBackground = Color(0xFFE6EDF7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 30),
                child: Column(
                  children: [
                    _bookingSummary(),
                    const SizedBox(height: 26),
                    _sectionTitle(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment Method',
                      subtitle: 'Choose your preferred payment option',
                    ),
                    const SizedBox(height: 14),
                    _paymentSection(),
                    const SizedBox(height: 26),
                    _sectionTitle(
                      icon: Icons.receipt_long_outlined,
                      title: 'Payment Summary',
                      subtitle: 'Review your parking charges',
                    ),
                    const SizedBox(height: 14),
                    _priceSection(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ActionButton(
                        label: 'Pay ₹${finalTotal.toStringAsFixed(0)}',
                        color: _blue,
                        foregroundColor: Colors.white,
                        onPressed: _payNow,
                      ),
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

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: _primaryText,
              size: 30,
            ),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Text(
              'Checkout',
              style: TextStyle(
                color: _primaryText,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _iconBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: _blue,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _iconBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: _blue,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookingSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    color: Colors.white,
                    size: 33,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot ${widget.slot.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.criteria.location,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Divider(
            color: Colors.white.withValues(alpha: 0.2),
            height: 1,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _dateInfo(
                  icon: Icons.login,
                  label: 'ENTRY',
                  value:
                  '${AppUtils.formatDate(widget.criteria.entryDate)}\n${AppUtils.formatTimeOfDay(widget.criteria.entryTime)}',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _dateInfo(
                  icon: Icons.logout,
                  label: 'EXIT',
                  value:
                  '${AppUtils.formatDate(widget.criteria.exitDate)}\n${AppUtils.formatTimeOfDay(widget.criteria.exitTime)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow(
            Icons.schedule_outlined,
            'Duration',
            _formatDuration(widget.duration),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.75),
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.75),
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
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

  Widget _paymentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _paymentOption(
            title: 'UPI',
            subtitle: 'Google Pay, PhonePe, Paytm and more',
            icon: Icons.account_balance_wallet_outlined,
            value: 'UPI',
          ),
          const Divider(height: 30),
          _paymentOption(
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard and RuPay',
            icon: Icons.credit_card_outlined,
            value: 'Card',
          ),
          const Divider(height: 30),
          _paymentOption(
            title: 'Cash at Parking',
            subtitle: 'Pay directly at the parking location',
            icon: Icons.payments_outlined,
            value: 'Cash',
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final selected = _paymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? _blue.withValues(alpha: 0.12) : _iconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: _blue,
                size: 27,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? _blue : const Color(0xFFB5BFCE),
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _priceRow(
            'Parking Fee',
            '₹${widget.total.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 18),
          _priceRow(
            'Service Fee',
            '₹${serviceFee.toStringAsFixed(0)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              height: 1,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
          _priceRow(
            'Total Amount',
            '₹${finalTotal.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String label,
      String value, {
        bool bold = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? _primaryText : _secondaryText,
              fontSize: bold ? 19 : 16,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: bold ? _blue : _primaryText,
            fontSize: bold ? 24 : 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  void _payNow() {
    final booking = widget.controller.bookSlot(
      slot: widget.slot,
      criteria: widget.criteria,
      timeRange:
      '${AppUtils.formatTimeOfDay(widget.criteria.entryTime)} - '
          '${AppUtils.formatTimeOfDay(widget.criteria.exitTime)}',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BookingConfirmationPage(
          booking: booking,
          controller: widget.controller,
          duration: widget.duration,
          total: finalTotal,
          paymentMethod: _paymentMethod,
        ),
      ),
    );
  }
}
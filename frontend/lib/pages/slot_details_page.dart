import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../controllers/parking_controller.dart';
import '../models/parking_slot.dart';
import '../models/search_criteria.dart';
import '../widgets/common/action_button.dart';
import 'checkout_page.dart';

class SlotDetailsPage extends StatefulWidget {
  const SlotDetailsPage({
    required this.slot,
    required this.criteria,
    required this.controller,
    super.key,
  });

  final ParkingSlot slot;
  final SearchCriteria criteria;
  final ParkingController controller;

  @override
  State<SlotDetailsPage> createState() => _SlotDetailsPageState();
}

class _SlotDetailsPageState extends State<SlotDetailsPage> {
  late TimeOfDay _entryTime;
  late TimeOfDay _exitTime;

  @override
  void initState() {
    super.initState();

    _entryTime = widget.criteria.entryTime;
    _exitTime = widget.criteria.exitTime;
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();
    final hours = duration.inMinutes / 60;
    final total = hours * 40;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSlotCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      icon: Icons.schedule_rounded,
                      title: 'Parking Time',
                      subtitle: 'Choose your entry and exit time',
                    ),
                    const SizedBox(height: 12),
                    _buildTimeCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      icon: Icons.receipt_long_rounded,
                      title: 'Booking Summary',
                      subtitle: 'Estimated parking cost',
                    ),
                    const SizedBox(height: 12),
                    _buildPriceCard(
                      duration: duration,
                      total: total,
                    ),
                    const SizedBox(height: 28),
                    ActionButton(
                      label: 'Proceed to Checkout',
                      color: AppColors.authPrimary,
                      foregroundColor: Colors.white,
                      onPressed: _proceed,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Slot Details',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.authPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_parking_rounded,
              color: AppColors.authPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.authPrimary,
            AppColors.brightBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Slot ${widget.slot.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 20),
          _buildSlotInfo(
            icon: Icons.location_on_rounded,
            label: 'PARKING LOCATION',
            value: widget.criteria.location,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSlotInfo(
                  icon: Icons.login_rounded,
                  label: 'ENTRY DATE',
                  value: AppUtils.formatDate(
                    widget.criteria.entryDate,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSlotInfo(
                  icon: Icons.logout_rounded,
                  label: 'EXIT DATE',
                  value: AppUtils.formatDate(
                    widget.criteria.exitDate,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: 19,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.authPrimary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: AppColors.authPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8A90A6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTimeTile(
            title: 'Entry Time',
            subtitle: 'When you enter the parking area',
            time: _entryTime,
            icon: Icons.login_rounded,
            onTap: () => _pickTime(isEntry: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: const Color(0xFFE8EAF0),
            ),
          ),
          _buildTimeTile(
            title: 'Exit Time',
            subtitle: 'When you leave the parking area',
            time: _exitTime,
            icon: Icons.logout_rounded,
            onTap: () => _pickTime(isEntry: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.authPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.authPrimary,
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
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8A90A6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatTimeOfDay(time),
                    style: const TextStyle(
                      color: AppColors.authPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF8A90A6),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard({
    required Duration duration,
    required double total,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Duration',
            '${duration.inMinutes ~/ 60} hr ${duration.inMinutes % 60} min',
          ),
          const SizedBox(height: 15),
          _buildPriceRow(
            'Parking Rate',
            '₹40 / hour',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(
              color: Color(0xFFE8EAF0),
              height: 1,
            ),
          ),
          _buildPriceRow(
            'Estimated Total',
            '₹${total.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
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
              color: bold
                  ? AppColors.textDark
                  : const Color(0xFF777E91),
              fontSize: bold ? 17 : 14,
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: bold
                ? AppColors.authPrimary
                : AppColors.textDark,
            fontSize: bold ? 22 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime({
    required bool isEntry,
  }) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isEntry
          ? _entryTime
          : _exitTime,
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      if (isEntry) {
        _entryTime = selected;
      } else {
        _exitTime = selected;
      }
    });
  }

  Duration _calculateDuration() {
    final entry = DateTime(
      widget.criteria.entryDate.year,
      widget.criteria.entryDate.month,
      widget.criteria.entryDate.day,
      _entryTime.hour,
      _entryTime.minute,
    );

    final exit = DateTime(
      widget.criteria.exitDate.year,
      widget.criteria.exitDate.month,
      widget.criteria.exitDate.day,
      _exitTime.hour,
      _exitTime.minute,
    );

    if (!exit.isAfter(entry)) {
      return Duration.zero;
    }

    return exit.difference(entry);
  }

  void _proceed() {
    final duration = _calculateDuration();

    if (duration == Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Exit time must be after entry time',
          ),
        ),
      );
      return;
    }

    final updatedCriteria = SearchCriteria(
      location: widget.criteria.location,
      entryDate: widget.criteria.entryDate,
      entryTime: _entryTime,
      exitDate: widget.criteria.exitDate,
      exitTime: _exitTime,
    );

    final total = (duration.inMinutes / 60) * 40;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          slot: widget.slot,
          criteria: updatedCriteria,
          controller: widget.controller,
          duration: duration,
          total: total,
        ),
      ),
    );
  }
}
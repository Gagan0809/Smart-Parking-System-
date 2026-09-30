import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../models/booking.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  bool _loading = true;

  static const backgroundColor = Color(0xFFF5F6FA);
  static const primaryBlue = Color(0xFF3269B3);
  static const darkText = Color(0xFF303B4A);
  static const secondaryText = Color(0xFF748093);

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    await widget.controller.loadAdminBookings();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text('Cancel booking ${booking.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE52424),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final bookings = widget.controller.adminBookingsBackendIds;
    final backendId = bookings[booking.id];

    if (backendId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify the booking record'),
        ),
      );
      return;
    }

    final success = await widget.controller.cancelAdminBooking(backendId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Booking cancelled' : 'Failed to cancel booking',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAdmin) {
      return _accessDenied();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        title: const Text(
          'Manage Bookings',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadBookings,
            icon: const Icon(
              Icons.refresh_rounded,
              color: primaryBlue,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final bookings = widget.controller.bookings;

                if (bookings.isEmpty) {
                  return RefreshIndicator(
                    color: primaryBlue,
                    onRefresh: _loadBookings,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: Text(
                            'No bookings found',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: primaryBlue,
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final userName = booking.userName?.isNotEmpty == true
                          ? booking.userName!
                          : 'User not stored';
                      final userEmail = booking.userEmail?.isNotEmpty == true
                          ? booking.userEmail!
                          : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
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
                                Expanded(
                                  child: Text(
                                    booking.id,
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF18A34A),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Text(
                                    'Confirmed',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _row('User', userName),
                            if (userEmail.isNotEmpty) _row('Email', userEmail),
                            _row('Slot', booking.slotId),
                            _row('Location', booking.location),
                            _row('Date', _formatDate(booking.entryDate)),
                            _row('Time', booking.timeRange),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _cancelBooking(booking),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel Booking'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE52424),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: darkText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString()}';
  }

  Widget _accessDenied() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        title: const Text('Access Denied'),
      ),
      body: const Center(
        child: Text(
          'Admin access required',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

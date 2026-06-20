import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../controllers/parking_controller.dart';
import '../models/booking.dart';
import '../widgets/common/page_header.dart';
import '../widgets/parking/booking_card.dart';
import '../widgets/parking/empty_bookings.dart';
import 'nearest_parking_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({required this.controller, super.key});

  final ParkingController controller;

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'My Bookings',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: widget.controller.bookings.isEmpty
                  ? EmptyBookings(onFindParking: _openHome)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                      itemBuilder: (context, index) {
                        final booking = widget.controller.bookings[index];
                        return BookingCard(
                          booking: booking,
                          onCancel: () => _confirmCancel(booking),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemCount: widget.controller.bookings.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => NearestParkingPage(controller: widget.controller)),
      (route) => false,
    );
  }

  Future<void> _confirmCancel(Booking booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text('Cancel ${booking.id} for Slot ${booking.slotId}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldCancel != true) return;

    widget.controller.cancelBooking(booking.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${booking.id} cancelled')));
  }
}

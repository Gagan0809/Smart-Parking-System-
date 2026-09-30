import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../core/utils.dart';
import '../widgets/parking/menu_action_tile.dart';
import 'booking_history_page.dart';
import 'bookings_page.dart';
import 'nearest_parking_page.dart';
import 'profile_page.dart';
import 'welcome_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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
    final userName = widget.controller.userName;
    final bookingCount = widget.controller.bookings.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  28,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildProfileHeader(
                    userName,
                    bookingCount,
                  ),
                  const SizedBox(height: 18),
                  MenuActionTile(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(
                            controller: widget.controller,
                          ),
                        ),
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.home_rounded,
                    title: 'Find Parking',
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => NearestParkingPage(
                            controller: widget.controller,
                          ),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.bookmark_rounded,
                    title: 'My Bookings',
                    badge: bookingCount == 0
                        ? null
                        : bookingCount.toString(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingsPage(
                            controller: widget.controller,
                          ),
                        ),
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.history_rounded,
                    title: 'Booking History',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingHistoryPage(
                            controller: widget.controller,
                          ),
                        ),
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.refresh_rounded,
                    title: 'Reset Demo Data',
                    onTap: () {
                      widget.controller.resetDemoData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demo data reset'),
                        ),
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Smart Parking System',
                        applicationVersion: '1.0.0',
                        children: const [
                          Text(
                            'A dynamic prototype for finding, booking, and managing parking slots.',
                          ),
                        ],
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
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
              'Menu',
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
              Icons.menu_rounded,
              color: primaryBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      String userName,
      int bookingCount,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Center(
              child: Text(
                AppUtils.avatarInitial(userName),
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$bookingCount active booking${bookingCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context,
      ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Return to the welcome screen?',
            style: TextStyle(
              color: secondaryText,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Stay',
                style: TextStyle(
                  color: secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    widget.controller.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => WelcomePage(
          controller: widget.controller,
        ),
      ),
          (route) => false,
    );
  }
}
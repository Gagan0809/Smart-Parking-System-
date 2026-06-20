import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../controllers/parking_controller.dart';
import '../widgets/common/page_header.dart';
import '../widgets/parking/menu_action_tile.dart';
import 'nearest_parking_page.dart';
import 'bookings_page.dart';
import 'welcome_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({required this.controller, super.key});

  final ParkingController controller;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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
    final userName = widget.controller.userName;
    final bookingCount = widget.controller.bookings.length;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Menu',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                children: [
                  _buildProfileHeader(userName, bookingCount),
                  const SizedBox(height: 18),
                  MenuActionTile(
                    icon: Icons.home,
                    title: 'Find Parking',
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => NearestParkingPage(controller: widget.controller)),
                        (route) => false,
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.bookmark,
                    title: 'My Bookings',
                    badge: bookingCount == 0 ? null : bookingCount.toString(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BookingsPage(controller: widget.controller)),
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.refresh,
                    title: 'Reset Demo Data',
                    onTap: () {
                      widget.controller.resetDemoData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo data reset')));
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Smart Parking System',
                        applicationVersion: '1.0.0',
                        children: const [
                          Text('A dynamic prototype for finding, booking, and managing parking slots.'),
                        ],
                      );
                    },
                  ),
                  MenuActionTile(
                    icon: Icons.logout,
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

  Widget _buildProfileHeader(String userName, int bookingCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              AppUtils.avatarInitial(userName),
              style: const TextStyle(
                color: AppColors.authPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bookingCount active booking${bookingCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Return to the welcome screen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      widget.controller.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => WelcomePage(controller: widget.controller)),
        (route) => false,
      );
    }
  }
}

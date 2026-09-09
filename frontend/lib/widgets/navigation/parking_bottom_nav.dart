import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ParkingBottomNav extends StatelessWidget {
  const ParkingBottomNav({
    required this.selectedIndex,
    required this.bookingCount,
    required this.onHome,
    required this.onBookings,
    required this.onMenu,
    required this.onSearch,
    super.key,
  });

  final int selectedIndex;
  final int bookingCount;
  final VoidCallback onHome;
  final VoidCallback onBookings;
  final VoidCallback onMenu;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 66,
              decoration: const BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.all(Radius.circular(33)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: selectedIndex == 0,
                      onTap: onHome,
                    ),
                  ),
                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.dashboard,
                      label: 'My Booking',
                      isSelected: selectedIndex == 1,
                      badge: bookingCount,
                      onTap: onBookings,
                    ),
                  ),
                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.menu,
                      label: 'Menu',
                      isSelected: selectedIndex == 2,
                      onTap: onMenu,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 66,
            height: 66,
            child: Material(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(33),
              child: InkWell(
                borderRadius: BorderRadius.circular(33),
                onTap: onSearch,
                child: const Tooltip(
                  message: 'Search',
                  child: Icon(Icons.search, color: Colors.black, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(33),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.black87,
                  size: 22,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black87,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: 10,
                right: 18,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.occupied,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

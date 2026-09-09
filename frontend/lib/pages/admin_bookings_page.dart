import 'package:flutter/material.dart';
import '../core/constants.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  static final List<Map<String, String>> bookings = [
    {
      'id': 'BK-2401',
      'user': 'Gagan',
      'slot': 'A-1',
      'location': 'PES UNIVERSITY',
      'date': '28/08/2026',
      'time': '7:00 AM - 9:00 AM',
      'amount': '₹85',
      'status': 'Confirmed',
    },
    {
      'id': 'BK-2400',
      'user': 'Rahul',
      'slot': 'B-2',
      'location': 'PES UNIVERSITY',
      'date': '28/08/2026',
      'time': '10:00 AM - 12:00 PM',
      'amount': '₹85',
      'status': 'Confirmed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Manage Bookings'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking['id']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.available,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        booking['status']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _row('User', booking['user']!),
                _row('Slot', booking['slot']!),
                _row('Location', booking['location']!),
                _row('Date', booking['date']!),
                _row('Time', booking['time']!),
                _row('Amount', booking['amount']!),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
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
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
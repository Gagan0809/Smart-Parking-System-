import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../controllers/parking_controller.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/common/primary_pill_button.dart';
import '../widgets/common/secondary_pill_button.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({required this.controller, super.key});

  final ParkingController controller;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),
          const Text('Smart Parking\nSystem', style: AppStyles.heading),
          const SizedBox(height: 26),
          const Text(
            'Find and book your parking spot\neasily.',
            style: AppStyles.subHeading,
          ),
          const Spacer(flex: 2),
          PrimaryPillButton(
            label: 'Login',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LoginPage(controller: controller),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          SecondaryPillButton(
            label: 'Sign Up',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SignUpPage(controller: controller),
                ),
              );
            },
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

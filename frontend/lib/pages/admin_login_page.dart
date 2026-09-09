import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../controllers/parking_controller.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/common/primary_pill_button.dart';
import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(
        children: [
          const Spacer(flex: 2),
          const Icon(
            Icons.admin_panel_settings,
            size: 60,
            color: AppColors.authPrimary,
          ),
          const SizedBox(height: 14),
          const Text(
            'Admin Login',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 40),
          AuthTextField(
            controller: _emailController,
            hintText: 'Admin Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 32),
          PrimaryPillButton(
            label: 'Admin Login',
            onPressed: _login,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Back',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = widget.controller.handleAdminAuthentication(
      email,
      password,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid admin email or password'),
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AdminDashboardPage(
          controller: widget.controller,
        ),
      ),
      (route) => false,
    );
  }
}
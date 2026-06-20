import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../controllers/parking_controller.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/common/primary_pill_button.dart';
import 'nearest_parking_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.controller, super.key});

  final ParkingController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Text(
              'Login',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 48),
            AuthTextField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: AppUtils.validateEmail,
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
              validator: AppUtils.validatePassword,
            ),
            const SizedBox(height: 40),
            PrimaryPillButton(label: 'Login', onPressed: _submit),
            const SizedBox(height: 16),
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
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final emailName = _emailController.text.trim().split('@').first;
    widget.controller.handleAuthentication(emailName);
    _openHome();
  }

  void _openHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => NearestParkingPage(controller: widget.controller),
      ),
      (route) => false,
    );
  }
}

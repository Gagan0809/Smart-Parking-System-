import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../controllers/parking_controller.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/common/primary_pill_button.dart';
import 'nearest_parking_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({required this.controller, super.key});

  final ParkingController controller;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
            const Spacer(flex: 1),
            const Text(
              'Create account',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 44),
            AuthTextField(
              controller: _nameController,
              hintText: 'Full Name',
              textCapitalization: TextCapitalization.words,
              validator: AppUtils.validateName,
            ),
            const SizedBox(height: 28),
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
            PrimaryPillButton(label: 'Sign Up', onPressed: _submit),
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
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.controller.handleAuthentication(_nameController.text.trim());
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

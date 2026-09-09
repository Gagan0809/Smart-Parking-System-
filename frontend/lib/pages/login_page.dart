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

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.authPrimary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.authPrimary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Welcome back',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Sign in to manage your parking bookings.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 42),

              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: AppUtils.validateEmail,
              ),

              const SizedBox(height: 24),

              const Text(
                'PASSWORD',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                controller: _passwordController,
                hintText: 'Enter your password',
                obscureText: true,
                validator: AppUtils.validatePassword,
              ),

              const SizedBox(height: 36),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                PrimaryPillButton(
                  label: 'Login',
                  onPressed: _submit,
                ),

              const SizedBox(height: 20),

              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                  ),
                  label: const Text('Back to welcome'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: Text(
                  'SMART PARKING SYSTEM',
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final emailName = _emailController.text.trim().split('@').first;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      widget.controller.handleAuthentication(emailName);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => NearestParkingPage(
            controller: widget.controller,
          ),
        ),
            (route) => false,
      );
    });
  }
}
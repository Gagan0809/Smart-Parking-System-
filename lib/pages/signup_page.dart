import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/common/primary_pill_button.dart';
import 'nearest_parking_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

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
      child: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.textDark.withValues(alpha: 0.10),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.authPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 34,
                      color: AppColors.authPrimary,
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Create your account',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Create an account to find and reserve\nparking spaces with ease.',
                    style: TextStyle(
                      color: Color(0xFF7A8196),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 38),

                  const Text(
                    'FULL NAME',
                    style: TextStyle(
                      color: Color(0xFF747B90),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AuthTextField(
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    textCapitalization: TextCapitalization.words,
                    validator: AppUtils.validateName,
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'EMAIL ADDRESS',
                    style: TextStyle(
                      color: Color(0xFF747B90),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: AppUtils.validateEmail,
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'PASSWORD',
                    style: TextStyle(
                      color: Color(0xFF747B90),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Create a secure password',
                    obscureText: true,
                    validator: AppUtils.validatePassword,
                  ),

                  const SizedBox(height: 32),

                  PrimaryPillButton(
                    label: _isLoading
                        ? 'Creating Account...'
                        : 'Create Account',
                    onPressed: _isLoading ? () {} : _submit,
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Already have an account? Log in',
                        style: TextStyle(
                          color: AppColors.authPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: Text(
                      'SMART PARKING SYSTEM',
                      style: TextStyle(
                        color: AppColors.textDark.withValues(alpha: 0.35),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await widget.controller.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => NearestParkingPage(
          controller: widget.controller,
        ),
      ),
          (route) => false,
    );
  }
}
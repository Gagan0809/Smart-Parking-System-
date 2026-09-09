import 'package:flutter/material.dart';
import 'package:capstone_project/core/constants.dart';
import 'package:capstone_project/controllers/parking_controller.dart';
import 'package:capstone_project/pages/welcome_page.dart';

void main() {
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatefulWidget {
  const SmartParkingApp({super.key});

  @override
  State<SmartParkingApp> createState() => _SmartParkingAppState();
}

class _SmartParkingAppState extends State<SmartParkingApp> {
  final _controller = ParkingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.authPrimary,
          surface: AppColors.authBackground,
        ),
        useMaterial3: true,
      ),
      home: WelcomePage(controller: _controller),
    );
  }
}

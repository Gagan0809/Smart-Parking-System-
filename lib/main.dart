import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'controllers/parking_controller.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatefulWidget {
  const SmartParkingApp({super.key});

  @override
  State<SmartParkingApp> createState() => _SmartParkingAppState();
}

class _SmartParkingAppState extends State<SmartParkingApp> {
  late final ParkingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ParkingController();
  }

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.authPrimary),
        scaffoldBackgroundColor: AppColors.authBackground,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: WelcomePage(controller: _controller),
    );
  }
}

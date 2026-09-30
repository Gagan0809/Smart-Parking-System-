import 'dart:async';

import 'package:flutter/material.dart';
import 'package:capstone_project/controllers/parking_controller.dart';
import 'package:capstone_project/core/constants.dart';
import 'package:capstone_project/pages/admin_dashboard_page.dart';
import 'package:capstone_project/pages/nearest_parking_page.dart';
import 'package:capstone_project/pages/welcome_page.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:capstone_project/services/notification_service.dart';

Future<void> initializeMapRenderer() async {
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;

  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    await mapsImplementation.initializeWithRenderer(
      AndroidMapRenderer.latest,
    );

    await mapsImplementation.warmup();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(initializeMapRenderer());

  await NotificationService.instance.initialize();

  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatefulWidget {
  const SmartParkingApp({super.key});

  @override
  State<SmartParkingApp> createState() => _SmartParkingAppState();
}

class _SmartParkingAppState extends State<SmartParkingApp> {
  final _controller = ParkingController();

  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuthentication();
  }

  Future<void> _initializeAuthentication() async {
    await _controller.loadToken();

    if (_controller.isLoggedIn) {
      unawaited(_controller.initializeRealtime());
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
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
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
      home: _controller.isLoggedIn
          ? _controller.isAdmin
              ? AdminDashboardPage(controller: _controller)
              : NearestParkingPage(controller: _controller)
          : WelcomePage(controller: _controller),
    );
  }
}

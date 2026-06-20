import 'package:flutter/material.dart';

class AppColors {
  static const authBackground = Color(0xFFF8F8FC);
  static const authPrimary = Color(0xFF4E629F);
  static const navy = Color(0xFF211E63);
  static const panel = Color(0xFF8185B4);
  static const panelDeep = Color(0xFF4B4B88);
  static const brightBlue = Color(0xFF0EA5E9);
  static const available = Color(0xFF48B544);
  static const occupied = Color(0xFFEF3F3A);
  static const occupiedCard = Color(0xFF3C3F3E);
  static const mapLand = Color(0xFFEDEBE2);
  static const textDark = Color(0xFF4F5878);
}

class AppStyles {
  static const heading = TextStyle(
    color: AppColors.textDark,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 0.94,
    letterSpacing: 0,
  );

  static const subHeading = TextStyle(
    color: Color(0xFF686A74),
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.55,
    letterSpacing: 0,
  );
}

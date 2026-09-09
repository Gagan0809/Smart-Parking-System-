import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF111827);

  static const primary = Color(0xFF1565D8);
  static const primaryDark = Color(0xFF0B3D91);
  static const primaryLight = Color(0xFFE8F1FF);

  static const navy = Color(0xFF0F1C2E);
  static const panel = Color(0xFFFFFFFF);
  static const panelDeep = Color(0xFF172B4D);

  static const brightBlue = Color(0xFF2F80ED);
  static const blueLight = Color(0xFFEAF3FF);

  static const available = Color(0xFF16A34A);
  static const availableLight = Color(0xFFDCFCE7);

  static const occupied = Color(0xFFDC2626);
  static const occupiedLight = Color(0xFFFEE2E2);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);

  static const occupiedCard = Color(0xFF1F2937);

  static const mapLand = Color(0xFFEFF2F5);

  static const textDark = Color(0xFF111827);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFFFFFFF);

  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFF0F1F3);

  static const authBackground = Color(0xFFF5F7FA);
  static const authPrimary = Color(0xFF1565D8);
}

class AppStyles {
  static const heading = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.8,
  );

  static const subHeading = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  static const pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const button = TextStyle(
    color: AppColors.textLight,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}

class AppSpacing {
  static const double xs = 6;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double small = 12;
  static const double medium = 18;
  static const double large = 24;
  static const double pill = 100;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const floating = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
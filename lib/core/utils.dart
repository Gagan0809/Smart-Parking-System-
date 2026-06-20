import 'package:flutter/material.dart';

class AppUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String avatarInitial(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'G' : trimmed[0].toUpperCase();
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Use at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if ((value ?? '').trim().length < 2) {
      return 'Name is required';
    }
    return null;
  }
}

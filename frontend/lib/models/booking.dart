import 'package:flutter/material.dart';

class Booking {
  const Booking({
    required this.id,
    required this.slotId,
    required this.location,
    required this.entryDate,
    required this.entryTime,
    required this.exitDate,
    required this.exitTime,
    required this.timeRange,
  });

  final String id;
  final String slotId;
  final String location;
  final DateTime entryDate;
  final TimeOfDay entryTime;
  final DateTime exitDate;
  final TimeOfDay exitTime;
  final String timeRange;
}

import 'package:flutter/material.dart';

class SearchCriteria {
  const SearchCriteria({
    required this.location,
    required this.entryDate,
    required this.entryTime,
    required this.exitDate,
    required this.exitTime,
    this.maxDistanceKm,
    this.maxPrice,
    this.availableOnly = false,
  });

  final String location;
  final DateTime entryDate;
  final TimeOfDay entryTime;
  final DateTime exitDate;
  final TimeOfDay exitTime;
  final double? maxDistanceKm;
  final double? maxPrice;
  final bool availableOnly;
}
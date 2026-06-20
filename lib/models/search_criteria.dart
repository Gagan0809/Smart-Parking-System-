import 'package:flutter/material.dart';

class SearchCriteria {
  const SearchCriteria({
    required this.location,
    required this.entryDate,
    required this.entryTime,
    required this.exitDate,
    required this.exitTime,
  });

  final String location;
  final DateTime entryDate;
  final TimeOfDay entryTime;
  final DateTime exitDate;
  final TimeOfDay exitTime;
}

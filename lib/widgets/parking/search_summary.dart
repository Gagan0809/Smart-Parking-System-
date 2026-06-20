import 'package:flutter/material.dart';
import '../../core/utils.dart';
import '../../models/search_criteria.dart';

class SearchSummary extends StatelessWidget {
  const SearchSummary({required this.criteria, super.key});

  final SearchCriteria criteria;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criteria.location,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${AppUtils.formatDate(criteria.entryDate)} ${AppUtils.formatTimeOfDay(criteria.entryTime)}'
            ' to ${AppUtils.formatDate(criteria.exitDate)} ${AppUtils.formatTimeOfDay(criteria.exitTime)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

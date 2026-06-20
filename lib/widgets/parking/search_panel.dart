import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../common/action_button.dart';
import 'picker_field.dart';

class SearchPanel extends StatelessWidget {
  const SearchPanel({
    required this.locationController,
    required this.locationFocusNode,
    required this.entryDate,
    required this.entryTime,
    required this.exitDate,
    required this.exitTime,
    required this.onPickEntryDate,
    required this.onPickEntryTime,
    required this.onPickExitDate,
    required this.onPickExitTime,
    required this.onSearch,
    required this.onClear,
    super.key,
  });

  final TextEditingController locationController;
  final FocusNode locationFocusNode;
  final DateTime? entryDate;
  final TimeOfDay? entryTime;
  final DateTime? exitDate;
  final TimeOfDay? exitTime;
  final VoidCallback onPickEntryDate;
  final VoidCallback onPickEntryTime;
  final VoidCallback onPickExitDate;
  final VoidCallback onPickExitTime;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
      child: Column(
        children: [
          TextField(
            controller: locationController,
            focusNode: locationFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: _inputDecoration('Location', Icons.place_outlined),
            style: const TextStyle(
              color: Color(0xFF333344),
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PickerField(
                  label: entryDate == null ? 'Entry Date' : AppUtils.formatDate(entryDate!),
                  icon: Icons.calendar_today,
                  onTap: onPickEntryDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PickerField(
                  label: entryTime == null
                      ? 'Entry time'
                      : AppUtils.formatTimeOfDay(entryTime!),
                  icon: Icons.schedule,
                  onTap: onPickEntryTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PickerField(
                  label: exitDate == null ? 'Exit Date' : AppUtils.formatDate(exitDate!),
                  icon: Icons.event_available,
                  onTap: onPickExitDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PickerField(
                  label: exitTime == null ? 'Exit Time' : AppUtils.formatTimeOfDay(exitTime!),
                  icon: Icons.access_time,
                  onTap: onPickExitTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Search',
                  color: AppColors.brightBlue,
                  foregroundColor: Colors.black,
                  onPressed: onSearch,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  label: 'Clear All',
                  color: const Color(0xFFE9E9E4),
                  foregroundColor: const Color(0xFF2A2A2A),
                  onPressed: onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF777783)),
      hintStyle: const TextStyle(
        color: Color(0xFF777783),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      filled: true,
      fillColor: const Color(0xFFE2E2E2),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
    );
  }
}

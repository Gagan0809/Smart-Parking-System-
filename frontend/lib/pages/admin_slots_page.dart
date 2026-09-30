import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../models/parking_slot.dart';

class AdminSlotsPage extends StatefulWidget {
  const AdminSlotsPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<AdminSlotsPage> createState() => _AdminSlotsPageState();
}

class _AdminSlotsPageState extends State<AdminSlotsPage> {
  bool _isLoading = true;
  bool _isSaving = false;

  static const backgroundColor = Color(0xFFF5F6FA);
  static const primaryBlue = Color(0xFF3269B3);
  static const darkText = Color(0xFF303B4A);
  static const secondaryText = Color(0xFF748093);
  static const lightBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
    });

    await widget.controller.loadParkingSlots();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showSlotDialog({ParkingSlot? slot}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _SlotDialog(slot: slot),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success;

    if (slot == null) {
      success = await widget.controller.addParkingSlot(
        slotId: result['slotId'] as String,
        location: result['location'] as String,
        status: 'available',
        timeSlots: result['timeSlots'] as List<String>,
        price: result['price'] as double,
      );
    } else {
      success = await widget.controller.updateParkingSlot(
        backendId: slot.backendId!,
        slotId: result['slotId'] as String,
        location: result['location'] as String,
        status: slot.isOccupied ? 'occupied' : 'available',
        timeSlots: result['timeSlots'] as List<String>,
        price: result['price'] as double,
        latitude: slot.latitude,
        longitude: slot.longitude,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? slot == null
                  ? 'Parking slot added successfully'
                  : 'Parking slot updated successfully'
              : 'Unable to save parking slot',
        ),
      ),
    );
  }

  Future<void> _toggleStatus(ParkingSlot slot) async {
    if (slot.backendId == null || _isSaving) {
      return;
    }

    final newStatus = slot.isOccupied ? 'available' : 'occupied';

    setState(() {
      _isSaving = true;
    });

    final success = await widget.controller.updateParkingSlot(
      backendId: slot.backendId!,
      slotId: slot.id,
      location: slot.location,
      status: newStatus,
      timeSlots: slot.timeSlots,
      price: slot.price,
      latitude: slot.latitude,
      longitude: slot.longitude,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Slot ${slot.id} updated'
              : 'Failed to update Slot ${slot.id}',
        ),
      ),
    );
  }

  Future<void> _deleteSlot(ParkingSlot slot) async {
    if (slot.backendId == null || _isSaving) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Slot'),
          content: Text('Delete Slot ${slot.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE52424),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await widget.controller.deleteParkingSlot(slot.backendId!);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Slot ${slot.id} deleted' : 'Failed to delete Slot ${slot.id}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAdmin) {
      return _accessDenied();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        title: const Text(
          'Manage Parking Slots',
          style: TextStyle(
            color: darkText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading || _isSaving ? null : _loadSlots,
            icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _isLoading || _isSaving ? null : () => _showSlotDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final slots = widget.controller.slots;
                final availableCount =
                    slots.where((slot) => !slot.isOccupied).length;
                final occupiedCount =
                    slots.where((slot) => slot.isOccupied).length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              'Available',
                              availableCount.toString(),
                              const Color(0xFF18A34A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              'Occupied',
                              occupiedCount.toString(),
                              const Color(0xFFE52424),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              'Total',
                              slots.length.toString(),
                              primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: slots.isEmpty
                          ? RefreshIndicator(
                              color: primaryBlue,
                              onRefresh: _loadSlots,
                              child: ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 180),
                                  Center(
                                    child: Text(
                                      'No parking slots',
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: primaryBlue,
                              onRefresh: _loadSlots,
                              child: ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  100,
                                ),
                                itemCount: slots.length,
                                itemBuilder: (context, index) {
                                  final slot = slots[index];
                                  final available = !slot.isOccupied;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.07,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: lightBlue,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'P',
                                              style: TextStyle(
                                                color: primaryBlue,
                                                fontSize: 27,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Slot ${slot.id}',
                                                style: const TextStyle(
                                                  color: darkText,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                slot.location.isEmpty
                                                    ? 'No location'
                                                    : slot.location,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: secondaryText,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹${slot.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  color: primaryBlue,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: _isSaving
                                                  ? null
                                                  : () =>
                                                      _toggleStatus(slot),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: available
                                                      ? const Color(0xFF18A34A)
                                                      : const Color(0xFFFF4D55),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  available
                                                      ? 'Available'
                                                      : 'Occupied',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: _isSaving ||
                                                          slot.backendId == null
                                                      ? null
                                                      : () => _showSlotDialog(
                                                            slot: slot,
                                                          ),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color: primaryBlue,
                                                    size: 22,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: _isSaving
                                                      ? null
                                                      : () => _deleteSlot(slot),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Color(0xFFE52424),
                                                    size: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _summaryCard(String title, String value, Color valueColor) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accessDenied() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        title: const Text('Access Denied'),
      ),
      body: const Center(
        child: Text(
          'Admin access required',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SlotDialog extends StatefulWidget {
  const _SlotDialog({this.slot});

  final ParkingSlot? slot;

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  late final TextEditingController _slotIdController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _timeSlotsController;

  @override
  void initState() {
    super.initState();
    final slot = widget.slot;
    _slotIdController = TextEditingController(text: slot?.id ?? '');
    _locationController = TextEditingController(text: slot?.location ?? '');
    _priceController = TextEditingController(
      text: slot?.price.toStringAsFixed(0) ?? '20',
    );
    _timeSlotsController = TextEditingController(
      text: slot?.timeSlots.join(', ') ?? '08:00 - 10:00, 12:00 - 14:00, 16:00 - 18:00',
    );
  }

  @override
  void dispose() {
    _slotIdController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _timeSlotsController.dispose();
    super.dispose();
  }

  void _submit() {
    final slotId = _slotIdController.text.trim();
    final location = _locationController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final timeSlots = _timeSlotsController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (slotId.isEmpty || location.isEmpty || price == null || timeSlots.isEmpty) {
      return;
    }

    Navigator.of(context).pop({
      'slotId': slotId,
      'location': location,
      'price': price,
      'timeSlots': timeSlots,
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.slot != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        editing ? 'Edit Parking Slot' : 'Add Parking Slot',
        style: const TextStyle(
          color: Color(0xFF303B4A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_slotIdController, 'Slot ID'),
            const SizedBox(height: 14),
            _field(_locationController, 'Location'),
            const SizedBox(height: 14),
            _field(
              _priceController,
              'Price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 14),
            _field(
              _timeSlotsController,
              'Time Slots',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3269B3),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(editing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF303B4A)),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

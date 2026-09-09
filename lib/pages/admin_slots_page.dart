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
  final TextEditingController _slotIdController = TextEditingController();
  final TextEditingController _locationController =
  TextEditingController(text: 'PES UNIVERSITY');

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  @override
  void dispose() {
    _slotIdController.dispose();
    _locationController.dispose();
    super.dispose();
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

  Future<void> _toggleStatus(ParkingSlot slot) async {
    if (slot.backendId == null) {
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

  Future<void> _addSlot() async {
    _slotIdController.clear();
    _locationController.text = 'PES UNIVERSITY';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Add Parking Slot',
            style: TextStyle(
              color: Color(0xFF303B4A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _slotIdController,
                style: const TextStyle(
                  color: Color(0xFF303B4A),
                ),
                decoration: InputDecoration(
                  labelText: 'Slot ID',
                  hintText: 'Example: D-1',
                  labelStyle: const TextStyle(
                    color: Color(0xFF748093),
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AA4B2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF3269B3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _locationController,
                style: const TextStyle(
                  color: Color(0xFF303B4A),
                ),
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: const TextStyle(
                    color: Color(0xFF748093),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF3269B3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF748093),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final id = _slotIdController.text.trim();
                final location = _locationController.text.trim();

                if (id.isEmpty || location.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop({
                  'id': id,
                  'location': location,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3269B3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await widget.controller.addParkingSlot(
      slotId: result['id']!,
      location: result['location']!,
      status: 'available',
      timeSlots: const [
        '08:00 - 10:00',
        '12:00 - 14:00',
        '16:00 - 18:00',
      ],
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
              ? 'Parking slot added'
              : 'Failed to add parking slot',
        ),
      ),
    );
  }

  Future<void> _deleteSlot(ParkingSlot slot) async {
    if (slot.backendId == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Slot',
            style: TextStyle(
              color: Color(0xFF303B4A),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete Slot ${slot.id}?',
            style: const TextStyle(
              color: Color(0xFF748093),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF748093),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52424),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success =
    await widget.controller.deleteParkingSlot(slot.backendId!);

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
              ? 'Slot ${slot.id} deleted'
              : 'Failed to delete Slot ${slot.id}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF303B4A),
          elevation: 0,
          title: const Text(
            'Access Denied',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Admin access required',
            style: TextStyle(
              color: Color(0xFF303B4A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final slots = widget.controller.slots;

    final availableCount =
        slots.where((slot) => !slot.isOccupied).length;

    final occupiedCount =
        slots.where((slot) => slot.isOccupied).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF303B4A),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Manage Parking Slots',
          style: TextStyle(
            color: Color(0xFF303B4A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading || _isSaving ? null : _loadSlots,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF3269B3),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3269B3),
        elevation: 5,
        onPressed: _isLoading || _isSaving ? null : _addSlot,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3269B3),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Available',
                    availableCount.toString(),
                    const Color(0xFF18A34A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Occupied',
                    occupiedCount.toString(),
                    const Color(0xFFE52424),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total',
                    slots.length.toString(),
                    const Color(0xFF3269B3),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: slots.isEmpty
                ? RefreshIndicator(
              color: const Color(0xFF3269B3),
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
                        color: Color(0xFF748093),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
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
                  margin:
                  const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.07),
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
                          color:
                          const Color(0xFFE8EDF5),
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              color:
                              Color(0xFF3269B3),
                              fontSize: 27,
                              fontWeight:
                              FontWeight.w900,
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
                                color:
                                Color(0xFF303B4A),
                                fontSize: 17,
                                fontWeight:
                                FontWeight.w800,
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
                                color:
                                Color(0xFF748093),
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w600,
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
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration:
                              BoxDecoration(
                                color: available
                                    ? const Color(
                                  0xFF18A34A,
                                )
                                    : const Color(
                                  0xFFFF4D55,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(12),
                              ),
                              child: Text(
                                available
                                    ? 'Available'
                                    : 'Occupied',
                                style:
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                            onPressed: _isSaving
                                ? null
                                : () =>
                                _deleteSlot(slot),
                            splashRadius: 22,
                            icon: const Icon(
                              Icons.delete_outline,
                              color:
                              Color(0xFFFF4D55),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      Color valueColor,
      ) {
    return Container(
      height: 96,
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF748093),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';
import '../models/parking_location.dart';

class AdminLocationsPage extends StatefulWidget {
  const AdminLocationsPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<AdminLocationsPage> createState() => _AdminLocationsPageState();
}

class _AdminLocationsPageState extends State<AdminLocationsPage> {
  bool _loading = true;
  bool _saving = false;

  static const backgroundColor = Color(0xFFF5F6FA);
  static const primaryBlue = Color(0xFF3269B3);
  static const darkText = Color(0xFF303B4A);
  static const secondaryText = Color(0xFF748093);
  static const lightBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    await widget.controller.loadParkingLocations();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _showLocationDialog({ParkingLocation? location}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _LocationDialog(location: location),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final backendId = location?.id;
    final bool success;

    if (backendId == null) {
      success = await widget.controller.addParkingLocation(
        name: result['name'] as String,
        address: result['address'] as String,
        latitude: result['latitude'] as double?,
        longitude: result['longitude'] as double?,
      );
    } else {
      success = await widget.controller.updateParkingLocation(
        backendId: backendId,
        name: result['name'] as String,
        address: result['address'] as String,
        slots: location?.slots ?? 0,
        status: result['status'] as String,
        latitude: result['latitude'] as double?,
        longitude: result['longitude'] as double?,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? backendId == null
                  ? 'Parking location added successfully'
                  : 'Parking location updated successfully'
              : 'Unable to save parking location',
        ),
      ),
    );
  }

  Future<void> _deleteLocation(ParkingLocation location) async {
    final backendId = location.id;

    if (backendId == null || backendId.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Location',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${location.name}?',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 15,
            ),
          ),
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
      _saving = true;
    });

    final success = await widget.controller.deleteParkingLocation(backendId);

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '${location.name} deleted' : 'Failed to delete location',
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
          'Manage Locations',
          style: TextStyle(
            color: darkText,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading || _saving ? null : _loadLocations,
            icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _loading || _saving ? null : () => _showLocationDialog(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final locations = widget.controller.parkingLocations;

                if (locations.isEmpty) {
                  return RefreshIndicator(
                    color: primaryBlue,
                    onRefresh: _loadLocations,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: Text(
                            'No parking locations',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: primaryBlue,
                  onRefresh: _loadLocations,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      return _buildLocationCard(locations[index]);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLocationCard(ParkingLocation location) {
    final isActive = location.status.toLowerCase() == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      location.address,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed:
                    _saving ? null : () => _showLocationDialog(location: location),
                icon: const Icon(Icons.edit_outlined, color: primaryBlue),
              ),
              IconButton(
                onPressed: _saving ? null : () => _deleteLocation(location),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE52424),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.local_parking, color: primaryBlue, size: 21),
              const SizedBox(width: 10),
              Text(
                '${location.slots} slots',
                style: const TextStyle(
                  color: darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF748093),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  location.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (location.latitude != null && location.longitude != null) ...[
            const SizedBox(height: 10),
            Text(
              'Coordinates: ${location.latitude}, ${location.longitude}',
              style: const TextStyle(
                color: secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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

class _LocationDialog extends StatefulWidget {
  const _LocationDialog({this.location});

  final ParkingLocation? location;

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    final location = widget.location;
    _nameController = TextEditingController(text: location?.name ?? '');
    _addressController = TextEditingController(text: location?.address ?? '');
    _latitudeController = TextEditingController(
      text: location?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: location?.longitude?.toString() ?? '',
    );
    _status = location?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      return;
    }

    Navigator.of(context).pop({
      'name': name,
      'address': address,
      'latitude': double.tryParse(_latitudeController.text.trim()),
      'longitude': double.tryParse(_longitudeController.text.trim()),
      'status': _status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.location != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        editing ? 'Edit Parking Location' : 'Add Parking Location',
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
            _field(
              controller: _nameController,
              label: 'Location Name',
            ),
            const SizedBox(height: 14),
            _field(
              controller: _addressController,
              label: 'Address',
            ),
            const SizedBox(height: 14),
            _field(
              controller: _latitudeController,
              label: 'Latitude',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            const SizedBox(height: 14),
            _field(
              controller: _longitudeController,
              label: 'Longitude',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            if (editing) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Inactive',
                    child: Text('Inactive'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
            ],
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF303B4A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF748093)),
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

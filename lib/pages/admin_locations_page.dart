import 'package:flutter/material.dart';
import '../controllers/parking_controller.dart';

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
  final List<Map<String, dynamic>> locations = [
    {
      'name': 'PES UNIVERSITY',
      'address': 'Electronic City, Bengaluru',
      'slots': 24,
      'status': 'Active',
    },
    {
      'name': 'PES CAMPUS NORTH',
      'address': 'Bengaluru',
      'slots': 18,
      'status': 'Active',
    },
  ];

  Future<void> _addLocation() async {
    String name = '';
    String address = '';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Add Parking Location',
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
                    onChanged: (value) {
                      name = value;
                    },
                    style: const TextStyle(
                      color: Color(0xFF303B4A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Location Name',
                      labelStyle: const TextStyle(
                        color: Color(0xFF748093),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (value) {
                      address = value;
                    },
                    style: const TextStyle(
                      color: Color(0xFF303B4A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: const TextStyle(
                        color: Color(0xFF748093),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
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
                    final trimmedName = name.trim();
                    final trimmedAddress = address.trim();

                    if (trimmedName.isEmpty || trimmedAddress.isEmpty) {
                      return;
                    }

                    Navigator.of(dialogContext).pop({
                      'name': trimmedName,
                      'address': trimmedAddress,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3269B3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      locations.add({
        'name': result['name'],
        'address': result['address'],
        'slots': 0,
        'status': 'Active',
      });
    });
  }

  Future<void> _deleteLocation(int index) async {
    final name = locations[index]['name'].toString();

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
              color: Color(0xFF303B4A),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete $name?',
            style: const TextStyle(
              color: Color(0xFF748093),
              fontSize: 15,
            ),
          ),
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
                  borderRadius: BorderRadius.circular(12),
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

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      locations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name deleted'),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF303B4A),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Manage Locations',
          style: TextStyle(
            color: Color(0xFF303B4A),
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3269B3),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _addLocation,
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
      body: locations.isEmpty
          ? const Center(
        child: Text(
          'No parking locations',
          style: TextStyle(
            color: Color(0xFF748093),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          100,
        ),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];

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
                        color: const Color(0xFFE8EDF5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF3269B3),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location['name'].toString(),
                            style: const TextStyle(
                              color: Color(0xFF303B4A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            location['address'].toString(),
                            style: const TextStyle(
                              color: Color(0xFF748093),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteLocation(index),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE52424),
                        size: 25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(
                  color: Colors.grey.withValues(alpha: 0.18),
                  height: 1,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.local_parking,
                      color: Color(0xFF3269B3),
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${location['slots']} slots',
                      style: const TextStyle(
                        color: Color(0xFF303B4A),
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
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        location['status'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
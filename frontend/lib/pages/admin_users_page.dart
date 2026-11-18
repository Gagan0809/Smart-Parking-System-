import 'package:flutter/material.dart';

import '../controllers/parking_controller.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({
    required this.controller,
    super.key,
  });

  final ParkingController controller;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _loading = true;

  static const backgroundColor = Color(0xFFF5F6FA);
  static const primaryBlue = Color(0xFF3269B3);
  static const darkText = Color(0xFF303B4A);
  static const secondaryText = Color(0xFF748093);
  static const lightBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await widget.controller.loadAdminUsers();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final id = user['id']?.toString();
    final role = user['role']?.toString().toUpperCase() ?? 'USER';
    final name = user['name']?.toString() ?? 'User';

    if (id == null || id.isEmpty) {
      return;
    }

    if (role == 'ADMIN') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin account cannot be deleted here'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Delete $name from the system?'),
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

    final success = await widget.controller.deleteAdminUser(id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'User deleted successfully' : 'Failed to delete user',
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
          'Manage Users',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadUsers,
            icon: const Icon(
              Icons.refresh_rounded,
              color: primaryBlue,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final users = widget.controller.adminUsers;

                if (users.isEmpty) {
                  return RefreshIndicator(
                    color: primaryBlue,
                    onRefresh: _loadUsers,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: Text(
                            'No users found',
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
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final name = user['name']?.toString() ?? 'Unnamed';
                      final email = user['email']?.toString() ?? '';
                      final role =
                          user['role']?.toString().toUpperCase() ?? 'USER';
                      final initial = name.isEmpty ? 'U' : name[0].toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: lightBlue,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: secondaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: role == 'ADMIN'
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF18A34A),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    role,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (role != 'ADMIN')
                                  IconButton(
                                    onPressed: () => _deleteUser(user),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFE52424),
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
              },
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

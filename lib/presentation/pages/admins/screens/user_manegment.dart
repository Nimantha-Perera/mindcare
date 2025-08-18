import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<DocumentSnapshot> _users = [];
  String _searchQuery = '';
  String _selectedRole = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper methods to determine device type
  bool isMobile(double width) => width < mobileBreakpoint;
  bool isTablet(double width) => width >= mobileBreakpoint && width < tabletBreakpoint;
  bool isDesktop(double width) => width >= tabletBreakpoint;
  bool isLargeDesktop(double width) => width >= desktopBreakpoint;

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('users').get();
      setState(() {
        _users = snapshot.docs;
      });
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<DocumentSnapshot> get _filteredUsers {
    return _users.where((user) {
      final data = user.data() as Map<String, dynamic>?;
      if (data == null) return false;

      final name = (data['name'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final role = data['role'] ?? 'user';

      final matchesSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRole == 'All' || role == _selectedRole.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Deletion'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showUserDialog({DocumentSnapshot? user}) async {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final roleController = TextEditingController(text: user?['role'] ?? 'user');

    return showDialog(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobileDevice = isMobile(screenWidth);
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: isMobileDevice ? screenWidth * 0.9 : 
                     screenWidth > 800 ? 500 : screenWidth * 0.8,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobileDevice ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Text(
                      isEditing ? 'Edit User' : 'Add New User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileDevice ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobileDevice ? 16 : 20),
                      child: Column(
                        children: [
                          _buildFormField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                            isMobile: isMobileDevice,
                          ),
                          SizedBox(height: isMobileDevice ? 16 : 20),
                          _buildFormField(
                            controller: emailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            isMobile: isMobileDevice,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: isMobileDevice ? 16 : 20),
                          _buildRoleDropdown(
                            controller: roleController,
                            isMobile: isMobileDevice,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobileDevice ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _saveUser(
                            nameController,
                            emailController,
                            roleController,
                            isEditing,
                            user,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileDevice ? 20 : 24,
                              vertical: isMobileDevice ? 10 : 12,
                            ),
                          ),
                          child: Text(isEditing ? 'Update User' : 'Add User'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isMobile,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown({
    required TextEditingController controller,
    required bool isMobile,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? 'user' : controller.text,
      decoration: InputDecoration(
        labelText: 'User Role',
        prefixIcon: const Icon(Icons.admin_panel_settings),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'user', child: Text('User')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
      ],
      onChanged: (value) {
        if (value != null) {
          controller.text = value;
        }
      },
    );
  }

  Future<void> _saveUser(
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController roleController,
    bool isEditing,
    DocumentSnapshot? user,
  ) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final role = roleController.text.trim();

    if (name.isEmpty || email.isEmpty || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (isEditing) {
        await _firestore.collection('users').doc(user!.id).update({
          'name': name,
          'email': email,
          'role': role,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('users').add({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'User updated successfully' : 'User added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSearchAndFilter(double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);

    return Container(
      padding: EdgeInsets.all(isMobileDevice ? 12 : 16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobileDevice ? 16 : 20,
                vertical: isMobileDevice ? 12 : 16,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          
          if (!isMobileDevice || isTabletDevice) ...[
            const SizedBox(height: 12),
            // Filter Row
            Row(
              children: [
                const Text('Filter by role: '),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Roles')),
                      DropdownMenuItem(value: 'User', child: Text('Users Only')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admins Only')),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            // Mobile filter chips
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedRole == 'All',
                  onSelected: (_) => setState(() => _selectedRole = 'All'),
                ),
                FilterChip(
                  label: const Text('Users'),
                  selected: _selectedRole == 'User',
                  onSelected: (_) => setState(() => _selectedRole = 'User'),
                ),
                FilterChip(
                  label: const Text('Admins'),
                  selected: _selectedRole == 'Admin',
                  onSelected: (_) => setState(() => _selectedRole = 'Admin'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserList(double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isDesktopDevice = isDesktop(screenWidth);
    final filteredUsers = _filteredUsers;

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: isMobileDevice ? 60 : 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No users found' : 'No users match your search',
              style: TextStyle(
                fontSize: isMobileDevice ? 16 : 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return isDesktopDevice ? _buildDesktopLayout(filteredUsers, screenWidth) : 
           _buildMobileLayout(filteredUsers, screenWidth);
  }

  Widget _buildMobileLayout(List<DocumentSnapshot> users, double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    
    return ListView.builder(
      padding: EdgeInsets.all(isMobileDevice ? 8 : 12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final data = user.data() as Map<String, dynamic>?;

        if (data == null) return const SizedBox();

        final name = data['name'] ?? 'Unnamed';
        final email = data['email'] ?? 'No Email';
        final role = data['role'] ?? 'user';

        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: isMobileDevice ? 4 : 8,
            vertical: isMobileDevice ? 4 : 6,
          ),
          elevation: isMobileDevice ? 1 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(isMobileDevice ? 12 : 16),
            leading: CircleAvatar(
              radius: isMobileDevice ? 20 : 24,
              backgroundColor: role == 'admin' ? Colors.orange.shade100 : Colors.teal.shade100,
              child: Icon(
                role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                color: role == 'admin' ? Colors.orange : Colors.teal,
                size: isMobileDevice ? 20 : 24,
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobileDevice ? 14 : 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: isMobileDevice ? 12 : 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == 'admin' ? Colors.orange : Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobileDevice ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteUser(user.id, name);
                } else if (value == 'edit') {
                  _showUserDialog(user: user);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(List<DocumentSnapshot> users, double screenWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: screenWidth),
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(
              label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: users.map((user) {
            final data = user.data() as Map<String, dynamic>?;
            if (data == null) return const DataRow(cells: []);

            final name = data['name'] ?? 'Unnamed';
            final email = data['email'] ?? 'No Email';
            final role = data['role'] ?? 'user';

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: role == 'admin' ? Colors.orange.shade100 : Colors.teal.shade100,
                        child: Icon(
                          role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                          color: role == 'admin' ? Colors.orange : Colors.teal,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(name),
                    ],
                  ),
                ),
                DataCell(Text(email)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: role == 'admin' ? Colors.orange : Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showUserDialog(user: user),
                        tooltip: 'Edit User',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _deleteUser(user.id, name),
                        tooltip: 'Delete User',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobileDevice = isMobile(screenWidth);
        final isDesktopDevice = isDesktop(screenWidth);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'User Management',
              style: TextStyle(
                fontSize: isMobileDevice ? 18 : isDesktopDevice ? 22 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 177, 177, 177),
            foregroundColor: Colors.white,
            centerTitle: isMobileDevice,
            elevation: isMobileDevice ? 2 : 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUsers,
                tooltip: 'Refresh',
              ),
              if (!isMobileDevice)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _showUserDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                    ),
                  ),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : Column(
                  children: [
                    _buildSearchAndFilter(screenWidth),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: _buildUserList(screenWidth),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: isMobileDevice
              ? FloatingActionButton(
                  onPressed: () => _showUserDialog(),
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
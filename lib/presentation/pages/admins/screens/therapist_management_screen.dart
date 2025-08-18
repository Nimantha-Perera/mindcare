import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TherapistManagementScreen extends StatefulWidget {
  const TherapistManagementScreen({super.key});

  @override
  State<TherapistManagementScreen> createState() => _TherapistManagementScreenState();
}

class _TherapistManagementScreenState extends State<TherapistManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _therapists = [];
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();
    _loadTherapists();
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

  Future<void> _loadTherapists() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('doctors').get();

      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _therapists = docs;
      });
    } catch (e) {
      print('Error loading therapists: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load therapists: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTherapists {
    return _therapists.where((therapist) {
      final name = (therapist['name'] ?? '').toString().toLowerCase();
      final specialty = (therapist['specialty'] ?? '').toString().toLowerCase();
      final about = (therapist['about'] ?? '').toString().toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          specialty.contains(_searchQuery.toLowerCase()) ||
          about.contains(_searchQuery.toLowerCase());

      final matchesSpecialty = _selectedSpecialty == 'All' ||
          specialty.contains(_selectedSpecialty.toLowerCase());

      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  Set<String> get _availableSpecialties {
    final specialties = _therapists
        .map((t) => (t['specialty'] ?? '').toString())
        .where((s) => s.isNotEmpty && s != 'Not specified')
        .toSet();
    return specialties;
  }

  Future<void> _deleteTherapist(String id, String name) async {
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
                text: name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '? This action cannot be undone and will affect all related appointments.'),
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
        await _firestore.collection('doctors').doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadTherapists();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting therapist: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showTherapistDialog({Map<String, dynamic>? therapist}) async {
    final isEditing = therapist != null;
    final nameController = TextEditingController(text: therapist?['name'] ?? '');
    final specialtyController = TextEditingController(text: therapist?['specialty'] ?? '');
    final aboutController = TextEditingController(text: therapist?['about'] ?? '');
    final profileImageController = TextEditingController(text: therapist?['profileImage'] ?? '');

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final isMobileDevice = isMobile(screenWidth);
              final isTabletDevice = isTablet(screenWidth);
              final isLandscape = screenWidth > screenHeight;
              
              // Responsive dialog sizing
              double dialogWidth;
              double maxDialogHeight;
              
              if (isMobileDevice) {
                dialogWidth = screenWidth * 0.95;
                maxDialogHeight = screenHeight * (isLandscape ? 0.95 : 0.85);
              } else if (isTabletDevice) {
                dialogWidth = screenWidth * 0.8;
                maxDialogHeight = screenHeight * 0.8;
              } else {
                dialogWidth = 600;
                maxDialogHeight = screenHeight * 0.85;
              }
              
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                insetPadding: EdgeInsets.all(isMobileDevice ? 8 : 16),
                child: Container(
                  width: dialogWidth,
                  constraints: BoxConstraints(
                    maxHeight: maxDialogHeight,
                    maxWidth: dialogWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobileDevice ? 16 : 20,
                          vertical: isMobileDevice ? 12 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isEditing ? Icons.edit : Icons.person_add,
                              color: Colors.white,
                              size: isMobileDevice ? 20 : 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isEditing ? 'Edit Therapist' : 'Add New Therapist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobileDevice ? 16 : isTabletDevice ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isMobileDevice)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobileDevice ? 16 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildResponsiveFormField(
                                controller: nameController,
                                label: 'Full Name',
                                icon: Icons.person,
                                screenWidth: screenWidth,
                                isRequired: true,
                              ),
                              SizedBox(height: isMobileDevice ? 16 : 20),
                              _buildResponsiveFormField(
                                controller: specialtyController,
                                label: 'Specialty',
                                icon: Icons.psychology,
                                screenWidth: screenWidth,
                                hint: 'e.g., Clinical Psychology, Cognitive Therapy',
                              ),
                              SizedBox(height: isMobileDevice ? 16 : 20),
                              _buildResponsiveFormField(
                                controller: aboutController,
                                label: 'About / Description',
                                icon: Icons.description,
                                screenWidth: screenWidth,
                                maxLines: isMobileDevice ? 3 : 4,
                                hint: 'Brief description of experience and approach',
                              ),
                              SizedBox(height: isMobileDevice ? 16 : 20),
                              _buildResponsiveFormField(
                                controller: profileImageController,
                                label: 'Profile Image URL',
                                icon: Icons.image,
                                screenWidth: screenWidth,
                                hint: 'Optional: Link to profile photo',
                                keyboardType: TextInputType.url,
                                onChanged: (value) {
                                  // Trigger rebuild to show/hide image preview
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: profileImageController,
                                builder: (context, value, child) {
                                  if (value.text.isEmpty) return const SizedBox.shrink();
                                  return Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      _buildResponsiveImagePreview(value.text, screenWidth),
                                    ],
                                  );
                                },
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
                        child: isMobileDevice ? 
                          // Mobile: Stack buttons vertically on small screens
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: () => _saveTherapist(
                                  nameController,
                                  specialtyController,
                                  aboutController,
                                  profileImageController,
                                  isEditing,
                                  therapist,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(isEditing ? 'Update Therapist' : 'Add Therapist'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ) :
                          // Desktop/Tablet: Horizontal layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _saveTherapist(
                                  nameController,
                                  specialtyController,
                                  aboutController,
                                  profileImageController,
                                  isEditing,
                                  therapist,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTabletDevice ? 20 : 24,
                                    vertical: isTabletDevice ? 10 : 12,
                                  ),
                                ),
                                child: Text(isEditing ? 'Update Therapist' : 'Add Therapist'),
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
        ),
      ),
    );
  }

  Widget _buildResponsiveFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double screenWidth,
    int maxLines = 1,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: isMobileDevice ? 14 : isTabletDevice ? 15 : 16,
      ),
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        labelStyle: TextStyle(
          fontSize: isMobileDevice ? 13 : isTabletDevice ? 14 : 15,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: isMobileDevice ? 12 : isTabletDevice ? 13 : 14,
        ),
        prefixIcon: Icon(
          icon, 
          size: isMobileDevice ? 20 : isTabletDevice ? 22 : 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobileDevice ? 12 : isTabletDevice ? 14 : 16,
          vertical: isMobileDevice ? 12 : isTabletDevice ? 14 : 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildResponsiveImagePreview(String url, double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileDevice ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                size: isMobileDevice ? 16 : 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Image Preview:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isMobileDevice ? 12 : isTabletDevice ? 13 : 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              height: isMobileDevice ? 100 : isTabletDevice ? 120 : 140,
              width: isMobileDevice ? 100 : isTabletDevice ? 120 : 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: isMobileDevice ? 100 : isTabletDevice ? 120 : 140,
                width: isMobileDevice ? 100 : isTabletDevice ? 120 : 140,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.red,
                      size: isMobileDevice ? 24 : 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invalid URL',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: isMobileDevice ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: isMobileDevice ? 100 : isTabletDevice ? 120 : 140,
                  width: isMobileDevice ? 100 : isTabletDevice ? 120 : 140,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: isMobileDevice ? 20 : 24,
                      height: isMobileDevice ? 20 : 24,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTherapist(
    TextEditingController nameController,
    TextEditingController specialtyController,
    TextEditingController aboutController,
    TextEditingController profileImageController,
    bool isEditing,
    Map<String, dynamic>? therapist,
  ) async {
    final name = nameController.text.trim();
    final specialty = specialtyController.text.trim();
    final about = aboutController.text.trim();
    final profileImage = profileImageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a therapist name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final data = {
        'name': name,
        'specialty': specialty.isEmpty ? 'Not specified' : specialty,
        'about': about.isEmpty ? 'No description provided' : about,
        'profileImage': profileImage,
        'availability': therapist?['availability'] ?? {},
      };

      if (isEditing) {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('doctors').doc(therapist!['id']).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('doctors').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Therapist updated successfully' : 'Therapist added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTherapists();
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
    final specialties = _availableSpecialties.toList()..sort();

    return Container(
      padding: EdgeInsets.all(isMobileDevice ? 12 : 16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search therapists by name, specialty, or description...',
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
          
          if (specialties.isNotEmpty) ...[
            SizedBox(height: isMobileDevice ? 12 : 16),
            // Filter Section
            if (!isMobileDevice || isTabletDevice) ...[
              Row(
                children: [
                  const Text('Filter by specialty: '),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedSpecialty,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: 'All', child: Text('All Specialties')),
                        ...specialties.map((specialty) =>
                            DropdownMenuItem(value: specialty, child: Text(specialty))),
                      ],
                      onChanged: (value) => setState(() => _selectedSpecialty = value!),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Mobile specialty chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedSpecialty == 'All',
                      onSelected: (_) => setState(() => _selectedSpecialty = 'All'),
                    ),
                    const SizedBox(width: 8),
                    ...specialties.map((specialty) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(specialty),
                        selected: _selectedSpecialty == specialty,
                        onSelected: (_) => setState(() => _selectedSpecialty = specialty),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTherapistList(double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isDesktopDevice = isDesktop(screenWidth);
    final filteredTherapists = _filteredTherapists;

    if (filteredTherapists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: isMobileDevice ? 60 : 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No therapists found' : 'No therapists match your search',
              style: TextStyle(
                fontSize: isMobileDevice ? 16 : 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first therapist to get started',
              style: TextStyle(
                fontSize: isMobileDevice ? 14 : 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return isDesktopDevice ? _buildDesktopGrid(filteredTherapists, screenWidth) : 
           _buildMobileList(filteredTherapists, screenWidth);
  }

  Widget _buildMobileList(List<Map<String, dynamic>> therapists, double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    
    return ListView.builder(
      padding: EdgeInsets.all(isMobileDevice ? 8 : 12),
      itemCount: therapists.length,
      itemBuilder: (context, index) {
        final therapist = therapists[index];
        return _buildTherapistCard(therapist, screenWidth);
      },
    );
  }

  Widget _buildDesktopGrid(List<Map<String, dynamic>> therapists, double screenWidth) {
    final isLargeDesktopDevice = isLargeDesktop(screenWidth);
    final crossAxisCount = isLargeDesktopDevice ? 3 : 2;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: therapists.length,
      itemBuilder: (context, index) {
        final therapist = therapists[index];
        return _buildTherapistCard(therapist, screenWidth, isGrid: true);
      },
    );
  }

  Widget _buildTherapistCard(Map<String, dynamic> therapist, double screenWidth, {bool isGrid = false}) {
    final isMobileDevice = isMobile(screenWidth);
    final name = therapist['name'] ?? 'Unnamed';
    final specialty = therapist['specialty'] ?? 'Not specified';
    final about = therapist['about'] ?? 'No description';
    final profileImage = therapist['profileImage'] ?? '';
    final id = therapist['id'];

    if (isGrid) {
      // Desktop grid card
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Header with image and actions
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                      backgroundColor: Colors.teal.shade100,
                      child: profileImage.isEmpty 
                        ? const Icon(Icons.psychology, size: 35, color: Colors.teal) 
                        : null,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showTherapistDialog(therapist: therapist);
                        } else if (value == 'delete') {
                          _deleteTherapist(id, name);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.blue),
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
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        specialty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        about,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile/tablet list card
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
            radius: isMobileDevice ? 24 : 28,
            backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
            backgroundColor: Colors.teal.shade100,
            child: profileImage.isEmpty 
              ? Icon(
                  Icons.psychology, 
                  size: isMobileDevice ? 24 : 28, 
                  color: Colors.teal,
                ) 
              : null,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobileDevice ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                about,
                style: TextStyle(fontSize: isMobileDevice ? 12 : 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showTherapistDialog(therapist: therapist);
              } else if (value == 'delete') {
                _deleteTherapist(id, name);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
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
    }
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
              'Therapist Management',
              style: TextStyle(
                fontSize: isMobileDevice ? 18 : isDesktopDevice ? 22 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 197, 197, 197),
            foregroundColor: Colors.white,
            centerTitle: isMobileDevice,
            elevation: isMobileDevice ? 2 : 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTherapists,
                tooltip: 'Refresh',
              ),
              if (!isMobileDevice)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _showTherapistDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Therapist'),
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
                        onRefresh: _loadTherapists,
                        child: _buildTherapistList(screenWidth),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: isMobileDevice
              ? FloatingActionButton(
                  onPressed: () => _showTherapistDialog(),
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
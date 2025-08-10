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

  @override
  void initState() {
    super.initState();
    _loadTherapists();
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load therapists: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTherapist(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Therapist'),
        content: const Text('Are you sure you want to delete this therapist?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('doctors').doc(id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Therapist deleted')),
        );
        _loadTherapists();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showAddTherapistDialog() async {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();
    final aboutController = TextEditingController();
    final profileImageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Therapist'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aboutController,
                decoration: const InputDecoration(
                  labelText: 'About',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: profileImageController,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              try {
                await _firestore.collection('doctors').add({
                  'name': nameController.text.trim(),
                  'specialty': specialtyController.text.trim().isEmpty 
                      ? 'Not specified' 
                      : specialtyController.text.trim(),
                  'about': aboutController.text.trim().isEmpty 
                      ? 'No description' 
                      : aboutController.text.trim(),
                  'profileImage': profileImageController.text.trim(),
                  'availability': {}, // Empty availability object
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Therapist added successfully')),
                );
                _loadTherapists();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding therapist: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTherapistDialog(Map<String, dynamic> therapist) async {
    final nameController = TextEditingController(text: therapist['name'] ?? '');
    final specialtyController = TextEditingController(text: therapist['specialty'] ?? '');
    final aboutController = TextEditingController(text: therapist['about'] ?? '');
    final profileImageController = TextEditingController(text: therapist['profileImage'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Therapist'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aboutController,
                decoration: const InputDecoration(
                  labelText: 'About',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: profileImageController,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              try {
                await _firestore.collection('doctors').doc(therapist['id']).update({
                  'name': nameController.text.trim(),
                  'specialty': specialtyController.text.trim().isEmpty 
                      ? 'Not specified' 
                      : specialtyController.text.trim(),
                  'about': aboutController.text.trim().isEmpty 
                      ? 'No description' 
                      : aboutController.text.trim(),
                  'profileImage': profileImageController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Therapist updated successfully')),
                );
                _loadTherapists();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating therapist: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Management'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTherapists),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTherapists,
              child: ListView.builder(
                itemCount: _therapists.length,
                itemBuilder: (context, index) {
                  final therapist = _therapists[index];

                  final about = therapist['about'] ?? 'No description';
                  final availability = therapist['availability'] ?? {};
                  final profileImage = therapist['profileImage'] ?? '';
                  final name = therapist['name'] ?? 'Unnamed';
                  final specialty = therapist['specialty'] ?? 'Not specified';
                  final id = therapist['id'];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                        backgroundColor: Colors.teal.shade100,
                        child: profileImage.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(name),
                      subtitle: Text('$specialty\n$about'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditTherapistDialog(therapist);
                          } else if (value == 'delete') {
                            _deleteTherapist(id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.blue),
                            title: Text('Edit'),
                          )),
                          const PopupMenuItem(value: 'delete', child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTherapistDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
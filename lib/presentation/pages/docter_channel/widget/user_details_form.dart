import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/doctor.dart';

class UserDetailsForm extends StatefulWidget {
  final Doctor doctor;

  const UserDetailsForm({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _symptomsController = TextEditingController();
  
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _selectedGender;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isEmergency = false;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _populateUserData();
  }

  void _populateUserData() {
    if (user != null) {
      // Auto-populate email and name from Firebase Auth
      _emailController.text = user!.email ?? '';
      _nameController.text = user!.displayName ?? '';
      
      // Load additional user data from Firestore if available
      _loadUserProfileFromFirestore();
    }
  }

  Future<void> _loadUserProfileFromFirestore() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        
        setState(() {
          // Only populate if the field is empty and data exists in Firestore
          if (_nameController.text.isEmpty && userData['name'] != null) {
            _nameController.text = userData['name'];
          }
          if (_phoneController.text.isEmpty && userData['phone'] != null) {
            _phoneController.text = userData['phone'];
          }
          if (_ageController.text.isEmpty && userData['age'] != null) {
            _ageController.text = userData['age'].toString();
          }
          if (_addressController.text.isEmpty && userData['address'] != null) {
            _addressController.text = userData['address'];
          }
          if (_selectedGender == null && userData['gender'] != null) {
            _selectedGender = userData['gender'];
          }
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Don't show error to user as this is optional functionality
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF6A4C93),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDoctorInfoCard(),
            _buildUserDetailsForm(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: widget.doctor.profileImage.isNotEmpty
                ? NetworkImage(widget.doctor.profileImage)
                : const NetworkImage('https://firebasestorage.googleapis.com/v0/b/mindcare-e9b55.firebasestorage.app/o/doctor-1295571_1280.png?alt=media&token=78b0acbb-a308-4d66-a326-3824a6eec953'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctor.specialty,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.doctor.rating} (${widget.doctor.reviews} reviews)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6A4C93).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LKR ${_formatCurrency(widget.doctor.consultationFee)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A4C93),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A4C93),
              ),
            ),
            const SizedBox(height: 20),
            
            // Full Name
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Age and Gender Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Age',
                    hint: 'Enter age',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 120) {
                        return 'Enter valid age';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Phone Number
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+94 71 234 5678',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Disable editing as it's from Firebase Auth
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter your address',
              icon: Icons.location_on,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A4C93),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date and Time Selection
            Row(
              children: [
                Expanded(child: _buildDateSelector()),
                const SizedBox(width: 16),
                Expanded(child: _buildTimeSelector()),
              ],
            ),
            const SizedBox(height: 16),
            
            // Symptoms/Reason
            _buildTextField(
              controller: _symptomsController,
              label: 'Reason for Visit',
              hint: 'Describe your symptoms or reason for consultation',
              icon: Icons.medical_services,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your symptoms';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Emergency Checkbox
            CheckboxListTile(
              value: _isEmergency,
              onChanged: (value) {
                setState(() {
                  _isEmergency = value ?? false;
                });
              },
              title: const Text('This is an emergency'),
              subtitle: const Text('Check if you need urgent medical attention'),
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6A4C93)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A4C93), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6A4C93)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A4C93), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select gender';
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF6A4C93)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF6A4C93)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedTime != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4C93),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available),
                      const SizedBox(width: 8),
                      Text(
                        'Book Appointment - LKR ${_formatCurrency(widget.doctor.consultationFee)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A4C93),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A4C93),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select an appointment date');
      return;
    }

    if (_selectedTime == null) {
      _showErrorSnackBar('Please select an appointment time');
      return;
    }

    if (user == null) {
      _showErrorSnackBar('You must be logged in to book an appointment');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create appointment data with correct field names
      final appointmentData = {
        // Fixed field names to match AppointmentSections expectations
        'patientId': user!.uid,  // Changed from 'userId' to 'patientId'
        'userId': user!.uid,     // Keep both for compatibility
        'userEmail': user!.email,
        'doctorId': widget.doctor.id ?? widget.doctor.name, // Use actual doctor ID if available
        'doctorName': widget.doctor.name,
        'doctorSpecialty': widget.doctor.specialty,
        'doctorImage': widget.doctor.profileImage,
        'patientName': _nameController.text.trim(),
        'patientAge': int.parse(_ageController.text.trim()),
        'patientGender': _selectedGender,
        'patientPhone': _phoneController.text.trim(),
        'patientEmail': _emailController.text.trim(),
        'patientAddress': _addressController.text.trim(),
        'appointmentDate': Timestamp.fromDate(_selectedDate!),
        'appointmentTime': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'symptoms': _symptomsController.text.trim(),
        'isEmergency': _isEmergency,
        'consultationFee': widget.doctor.consultationFee.toDouble(), // Ensure it's double
        'status': 'upcoming', // Changed from 'pending' to 'upcoming'
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Creating appointment with data: $appointmentData');
      print('Current user ID: ${user!.uid}');

      // Add appointment to Firestore
      DocumentReference appointmentRef = await _firestore
          .collection('appointments')
          .add(appointmentData);

      // Update user profile in Firestore with latest information
      await _updateUserProfile();

      print('Appointment created with ID: ${appointmentRef.id}');
      
      // Show success dialog
      _showSuccessDialog(appointmentRef.id);
      
    } catch (e) {
      print('Error creating appointment: $e');
      _showErrorSnackBar('Failed to book appointment. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _updateUserProfile() async {
    if (user == null) return;

    try {
      // Update user profile with the latest information
      final userProfileData = {
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'gender': _selectedGender,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user!.uid)
          .set(userProfileData, SetOptions(merge: true));

    } catch (e) {
      print('Error updating user profile: $e');
      // Don't show error to user as this is optional
    }
  }

  void _showSuccessDialog(String appointmentId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on a small screen
          bool isSmallScreen = constraints.maxWidth < 600;
          double dialogWidth = isSmallScreen 
              ? constraints.maxWidth * 0.9 
              : constraints.maxWidth * 0.4;
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: constraints.maxHeight * 0.8,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Appointment Booked!',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      
                      // Success message
                      Text(
                        'Your appointment has been successfully booked.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      
                      // Appointment Details Container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Appointment ID',
                              '${appointmentId.substring(0, 8)}...',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Doctor',
                              widget.doctor.name,
                              isSmallScreen,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Date',
                              '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Time',
                              _selectedTime!.format(context),
                              isSmallScreen,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Fee',
                              'LKR ${_formatCurrency(widget.doctor.consultationFee)}',
                              isSmallScreen,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            
                            // Status Badge
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 8 : 12,
                                  vertical: isSmallScreen ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Status: Pending Confirmation',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      
                      // Information text
                      Text(
                        'You will receive a confirmation call/SMS shortly. You can view your appointments in your profile.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 13 : 14,
                          height: 1.4,
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Go back to previous screen
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// Helper method for building detail rows
Widget _buildDetailRow(String label, String value, bool isSmallScreen) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: isSmallScreen ? 80 : 100,
        child: Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 13 : 14,
            color: Colors.grey[700],
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}
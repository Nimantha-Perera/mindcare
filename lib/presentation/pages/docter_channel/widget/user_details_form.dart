import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/appoiment_details.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/doctor_info_card.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/patient_infomation_form.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/submite_btn.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/success_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _populateUserData();
  }

  void _populateUserData() {
    if (user != null) {
      _emailController.text = user!.email ?? '';
      _nameController.text = user!.displayName ?? '';
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
      appBar: _buildAppBar(context),
      body: _buildResponsiveBody(context),
      bottomNavigationBar: SubmitButton(
        isLoading: _isLoading,
        consultationFee: widget.doctor.consultationFee,
        onSubmit: _submitAppointment,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Book Appointment'),
      backgroundColor: const Color(0xFF6A4C93),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: MediaQuery.of(context).size.width < 600,
    );
  }

  Widget _buildResponsiveBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DoctorInfoCard(doctor: widget.doctor),
          const SizedBox(height: 16),
          _buildFormContent(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: DoctorInfoCard(doctor: widget.doctor),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildFormContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    DoctorInfoCard(doctor: widget.doctor),
                    const SizedBox(height: 24),
                    _buildFormContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PatientInformationForm(
            nameController: _nameController,
            ageController: _ageController,
            phoneController: _phoneController,
            emailController: _emailController,
            addressController: _addressController,
            selectedGender: _selectedGender,
            onGenderChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 24),
          AppointmentDetailsForm(
            symptomsController: _symptomsController,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            isEmergency: _isEmergency,
            onDateSelected: (date) => setState(() => _selectedDate = date),
            onTimeSelected: (time) => setState(() => _selectedTime = time),
            onEmergencyChanged: (value) => setState(() => _isEmergency = value),
          ),
        ],
      ),
    );
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

    setState(() => _isLoading = true);

    try {
      final appointmentData = {
        'patientId': user!.uid,
        'userId': user!.uid,
        'userEmail': user!.email,
        'doctorId': widget.doctor.id ?? widget.doctor.name,
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
        'consultationFee': widget.doctor.consultationFee.toDouble(),
        'status': 'upcoming',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference appointmentRef = await _firestore
          .collection('appointments')
          .add(appointmentData);

      await _updateUserProfile();
      
      if (mounted) {
        _showSuccessDialog(appointmentRef.id);
      }
      
    } catch (e) {
      print('Error creating appointment: $e');
      _showErrorSnackBar('Failed to book appointment. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (user == null) return;

    try {
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
    }
  }

  void _showSuccessDialog(String appointmentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        appointmentId: appointmentId,
        doctor: widget.doctor,
        selectedDate: _selectedDate!,
        selectedTime: _selectedTime!,
        onClose: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
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
}
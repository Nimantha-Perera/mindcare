import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/appoiment_details.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/doctor_info_card.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/patient_infomation_form.dart';
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
  
  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _selectedGender;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isEmergency = false;
  bool _isLoading = false;
  
  // Payment related variables
  String _selectedPaymentMethod = 'card';
  bool _showPaymentForm = false;
  String _cardType = '';

  @override
  void initState() {
    super.initState();
    _populateUserData();
  }

  void _populateUserData() {
    if (user != null) {
      _emailController.text = user!.email ?? '';
      _nameController.text = user!.displayName ?? '';
      _cardHolderController.text = user!.displayName ?? '';
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
            _cardHolderController.text = userData['name'];
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

  String _getCardType(String cardNumber) {
    if (cardNumber.isEmpty) return '';
    
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith(RegExp(r'5[1-5]'))) {
      return 'MasterCard';
    } else if (cardNumber.startsWith(RegExp(r'3[47]'))) {
      return 'American Express';
    } else if (cardNumber.startsWith('6011')) {
      return 'Discover';
    }
    return 'Unknown';
  }

  void _onCardNumberChanged(String value) {
    setState(() {
      _cardType = _getCardType(value.replaceAll(' ', ''));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _symptomsController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: _buildResponsiveBody(context),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_showPaymentForm ? 'Payment Details' : 'Book Appointment'),
      backgroundColor: const Color(0xFF6A4C93),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: MediaQuery.of(context).size.width < 600,
      leading: _showPaymentForm 
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showPaymentForm = false),
          )
        : null,
    );
  }

  Widget _buildResponsiveBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    if (_showPaymentForm) {
      return _buildPaymentForm();
    }

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

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentSummary(),
          const SizedBox(height: 24),
          _buildPaymentMethodSelection(),
          const SizedBox(height: 24),
          if (_selectedPaymentMethod == 'card') _buildCardPaymentForm(),
          if (_selectedPaymentMethod == 'mobile') _buildMobilePaymentForm(),
          if (_selectedPaymentMethod == 'bank') _buildBankTransferForm(),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Consultation Fee:', style: TextStyle(fontSize: 16)),
                Text(
                  'LKR ${widget.doctor.consultationFee.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (_isEmergency) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Emergency Fee:', style: TextStyle(fontSize: 16)),
                  Text(
                    'LKR ${(widget.doctor.consultationFee * 0.5).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'LKR ${(_isEmergency ? widget.doctor.consultationFee * 1.5 : widget.doctor.consultationFee).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A4C93)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption('card', Icons.credit_card, 'Credit/Debit Card'),
            _buildPaymentOption('mobile', Icons.phone_android, 'Mobile Payment'),
            _buildPaymentOption('bank', Icons.account_balance, 'Bank Transfer'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon, String title) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPaymentMethod == value 
              ? const Color(0xFF6A4C93) 
              : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _selectedPaymentMethod == value 
            ? const Color(0xFF6A4C93).withOpacity(0.1) 
            : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedPaymentMethod == value 
                ? const Color(0xFF6A4C93) 
                : Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: _selectedPaymentMethod == value 
                  ? FontWeight.bold 
                  : FontWeight.normal,
                color: _selectedPaymentMethod == value 
                  ? const Color(0xFF6A4C93) 
                  : Colors.black,
              ),
            ),
            const Spacer(),
            if (_selectedPaymentMethod == value)
              const Icon(Icons.check_circle, color: Color(0xFF6A4C93)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              onChanged: _onCardNumberChanged,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: const Icon(Icons.credit_card),
                suffixIcon: _cardType.isNotEmpty 
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_cardType, style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (value.replaceAll(' ', '').length < 13) {
                  return 'Please enter a valid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card holder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter expiry date';
                      }
                      if (value.length < 5) {
                        return 'Invalid expiry date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter CVV';
                      }
                      if (value.length < 3) {
                        return 'Invalid CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePaymentForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mobile Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMobilePaymentOption('eZ Cash', 'assets/images/ezcash.png'),
            _buildMobilePaymentOption('mCash', 'assets/images/mcash.png'),
            _buildMobilePaymentOption('UPAY', 'assets/images/upay.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePaymentOption(String name, String assetPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: const Icon(Icons.phone_android, color: Color(0xFF6A4C93)),
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bank Transfer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBankInfo('Bank Name', 'Commercial Bank of Ceylon'),
            _buildBankInfo('Account Name', 'MindCare Medical Services'),
            _buildBankInfo('Account Number', '8001234567'),
            _buildBankInfo('Branch Code', '001'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please include your appointment reference in the transfer description.',
                      style: TextStyle(fontSize: 14),
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

  Widget _buildBankInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleButtonPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4C93),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _showPaymentForm 
                      ? 'Pay LKR ${(_isEmergency ? widget.doctor.consultationFee * 1.5 : widget.doctor.consultationFee).toStringAsFixed(2)}'
                      : 'Continue to Payment',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleButtonPress() {
    if (!_showPaymentForm) {
      // Validate appointment form first
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

      setState(() => _showPaymentForm = true);
    } else {
      // Process payment
      _processPayment();
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'card') {
      // Validate card form
      if (_cardNumberController.text.isEmpty ||
          _cardHolderController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        _showErrorSnackBar('Please fill all card details');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create appointment after successful payment
      await _submitAppointment();
      
    } catch (e) {
      print('Payment error: $e');
      _showErrorSnackBar('Payment failed. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAppointment() async {
    if (user == null) {
      _showErrorSnackBar('You must be logged in to book an appointment');
      return;
    }

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
        'totalAmount': (_isEmergency ? widget.doctor.consultationFee * 1.5 : widget.doctor.consultationFee).toDouble(),
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': 'paid',
        'status': 'upcoming',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference appointmentRef = await _firestore
          .collection('appointments')
          .add(appointmentData);

      // Store payment record
      await _storePaymentRecord(appointmentRef.id);

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

  Future<void> _storePaymentRecord(String appointmentId) async {
    try {
      final paymentData = {
        'appointmentId': appointmentId,
        'patientId': user!.uid,
        'doctorId': widget.doctor.id ?? widget.doctor.name,
        'amount': (_isEmergency ? widget.doctor.consultationFee * 1.5 : widget.doctor.consultationFee).toDouble(),
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': 'completed',
        'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_selectedPaymentMethod == 'card') {
        paymentData['cardLastFour'] = _cardNumberController.text.replaceAll(' ', '').substring(
          _cardNumberController.text.replaceAll(' ', '').length - 4
        );
        paymentData['cardType'] = _cardType;
      }

      await _firestore.collection('payments').add(paymentData);
    } catch (e) {
      print('Error storing payment record: $e');
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

// Custom input formatters for card details
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.length <= 4) {
      return newValue;
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.length <= 2) {
      return newValue;
    }
    
    if (newText.length <= 4) {
      final month = newText.substring(0, 2);
      final year = newText.substring(2);
      final formattedText = '$month/$year';
      
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    
    return oldValue;
  }
}
import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/custom_textfeild.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/form_validator.dart';

class PatientInformationForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;

  const PatientInformationForm({
    Key? key,
    required this.nameController,
    required this.ageController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.selectedGender,
    required this.onGenderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Information',
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6A4C93),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          
          // Full Name
          CustomTextField(
            controller: nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person,
            validator: FormValidators.validateName,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Age and Gender Row
          _buildAgeGenderRow(context, isTablet),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Phone Number
          CustomTextField(
            controller: phoneController,
            label: 'Phone Number',
            hint: '+94 71 234 5678',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: FormValidators.validatePhone,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Email
          CustomTextField(
            controller: emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            enabled: false,
            validator: FormValidators.validateEmail,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Address
          CustomTextField(
            controller: addressController,
            label: 'Address',
            hint: 'Enter your address',
            icon: Icons.location_on,
            maxLines: 2,
            validator: FormValidators.validateAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGenderRow(BuildContext context, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          // Stack vertically on very small screens
          return Column(
            children: [
              CustomTextField(
                controller: ageController,
                label: 'Age',
                hint: 'Enter age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: FormValidators.validateAge,
              ),
              const SizedBox(height: 16),
              _buildGenderDropdown(context, isTablet),
            ],
          );
        } else {
          // Use row layout
          return Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: ageController,
                  label: 'Age',
                  hint: 'Enter age',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  validator: FormValidators.validateAge,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderDropdown(context, isTablet),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildGenderDropdown(BuildContext context, bool isTablet) {
    final List<String> genderOptions = ['Male', 'Female', 'Other'];
    
    return DropdownButtonFormField<String>(
      value: selectedGender,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 16 : 12,
        ),
      ),
      items: genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: onGenderChanged,
      validator: FormValidators.validateGender,
    );
  }
}
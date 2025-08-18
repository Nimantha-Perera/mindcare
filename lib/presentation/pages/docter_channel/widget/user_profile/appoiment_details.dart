import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/custom_textfeild.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/datetime_selector.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/form_validator.dart';


class AppointmentDetailsForm extends StatelessWidget {
  final TextEditingController symptomsController;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final bool isEmergency;
  final ValueChanged<DateTime?> onDateSelected;
  final ValueChanged<TimeOfDay?> onTimeSelected;
  final ValueChanged<bool> onEmergencyChanged;

  const AppointmentDetailsForm({
    Key? key,
    required this.symptomsController,
    required this.selectedDate,
    required this.selectedTime,
    required this.isEmergency,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onEmergencyChanged,
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
            'Appointment Details',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6A4C93),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Date and Time Selection
          _buildDateTimeRow(context, isTablet),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Symptoms/Reason
          CustomTextField(
            controller: symptomsController,
            label: 'Reason for Visit',
            hint: 'Describe your symptoms or reason for consultation',
            icon: Icons.medical_services,
            maxLines: 3,
            validator: FormValidators.validateSymptoms,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Emergency Checkbox
          _buildEmergencyCheckbox(context),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow(BuildContext context, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          // Stack vertically on small screens
          return Column(
            children: [
              DateTimeSelectors.buildDateSelector(
                context: context,
                selectedDate: selectedDate,
                onDateSelected: onDateSelected,
                fullWidth: true,
              ),
              const SizedBox(height: 16),
              DateTimeSelectors.buildTimeSelector(
                context: context,
                selectedTime: selectedTime,
                onTimeSelected: onTimeSelected,
                fullWidth: true,
              ),
            ],
          );
        } else {
          // Use row layout
          return Row(
            children: [
              Expanded(
                child: DateTimeSelectors.buildDateSelector(
                  context: context,
                  selectedDate: selectedDate,
                  onDateSelected: onDateSelected,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DateTimeSelectors.buildTimeSelector(
                  context: context,
                  selectedTime: selectedTime,
                  onTimeSelected: onTimeSelected,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildEmergencyCheckbox(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: CheckboxListTile(
        value: isEmergency,
        onChanged: (value) => onEmergencyChanged(value ?? false),
        title: Text(
          'This is an emergency',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        subtitle: Text(
          'Check if you need urgent medical attention',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isTablet ? 14 : 12,
          ),
        ),
        activeColor: Colors.red,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 8 : 4,
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
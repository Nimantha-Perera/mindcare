import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/currency_formatter.dart';

class SuccessDialog extends StatelessWidget {
  final String appointmentId;
  final Doctor doctor;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onClose;

  const SuccessDialog({
    Key? key,
    required this.appointmentId,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final dialogWidth = isSmallScreen 
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
                    _buildHeader(context, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildSuccessMessage(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildAppointmentDetails(context, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildInfoText(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    _buildActionButton(isSmallScreen),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
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
              color: const Color(0xFF6A4C93),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage(bool isSmallScreen) {
    return Text(
      'Your appointment has been successfully booked.',
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildAppointmentDetails(BuildContext context, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6A4C93),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildDetailRow(
            'Appointment ID',
            '${appointmentId.substring(0, 8)}...',
            isSmallScreen,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Doctor',
            doctor.name,
            isSmallScreen,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Date',
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            isSmallScreen,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Time',
            selectedTime.format(context),
            isSmallScreen,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Fee',
            'LKR ${CurrencyFormatter.format(doctor.consultationFee)}',
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildStatusBadge(isSmallScreen),
        ],
      ),
    );
  }

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

  Widget _buildStatusBadge(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: isSmallScreen ? 14 : 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Status: Pending Confirmation',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: isSmallScreen ? 18 : 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You will receive a confirmation call/SMS shortly. You can view your appointments in your profile.',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: isSmallScreen ? 13 : 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A4C93),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          'OK',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
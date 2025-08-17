import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindcare/data/datasources/appiment_datasource.dart';

import '../../../../data/models/appoiment_modal.dart';



class AppointmentDetailsModal extends StatelessWidget {
  final Appointment appointment;
  final bool isAdmin;
  final Function(String) onUpdateStatus;
  final VoidCallback onCall;

  const AppointmentDetailsModal({
    Key? key,
    required this.appointment,
    this.isAdmin = false,
    required this.onUpdateStatus,
    required this.onCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (appointment.isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Information Section
                  _buildSectionHeader('Patient Information', Icons.person),
                  const SizedBox(height: 12),
                  _buildDetailCard([
                    _buildDetailRow('Name', appointment.patientName),
                    _buildDetailRow('Age', '${appointment.patientAge} years old'),
                    _buildDetailRow('Gender', appointment.patientGender),
                    _buildDetailRow('Phone', appointment.patientPhone),
                    _buildDetailRow('Email', appointment.patientEmail),
                    _buildDetailRow('Address', appointment.patientAddress),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Doctor Information Section
                  _buildSectionHeader('Doctor Information', Icons.local_hospital),
                  const SizedBox(height: 12),
                  _buildDetailCard([
                    _buildDetailRow('Name', appointment.doctorName),
                    _buildDetailRow('Specialty', appointment.doctorSpecialty),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Appointment Information Section
                  _buildSectionHeader('Appointment Information', Icons.event),
                  const SizedBox(height: 12),
                  _buildDetailCard([
                    _buildDetailRow(
                      'Date',
                      DateFormat('EEEE, MMMM dd, yyyy').format(appointment.appointmentDate),
                    ),
                    _buildDetailRow('Time', appointment.appointmentTime),
                    _buildDetailRow(
                      'Status',
                      appointment.status.toUpperCase(),
                    ),
                    _buildDetailRow(
                      'Consultation Fee',
                      'LKR ${AppointmentService.formatCurrency(appointment.consultationFee.toInt())}',
                    ),
                    if (appointment.createdAt != null)
                      _buildDetailRow(
                        'Booked On',
                        DateFormat('MMM dd, yyyy at hh:mm a').format(appointment.createdAt!),
                      ),
                  ]),
                  
                  if (appointment.symptoms != null && appointment.symptoms!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Symptoms/Reason', Icons.medical_services),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        appointment.symptoms!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Admin Actions
                  if (isAdmin) ...[
                    _buildSectionHeader('Admin Actions', Icons.admin_panel_settings),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onCall,
                            icon: const Icon(Icons.phone),
                            label: const Text('Call Patient'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showQuickStatusUpdate(context),
                            icon: const Icon(Icons.edit),
                            label: const Text('Update Status'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6A4C93),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6A4C93), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A4C93),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickStatusUpdate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Mark as Upcoming'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                onUpdateStatus('upcoming');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as Completed'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                onUpdateStatus('completed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Mark as Cancelled'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                onUpdateStatus('cancelled');
              },
            ),
          ],
        ),
      ),
    );
  }
}
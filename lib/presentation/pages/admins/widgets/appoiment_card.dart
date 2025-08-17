import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindcare/data/datasources/appiment_datasource.dart';
import 'package:mindcare/presentation/pages/admins/widgets/appoiment_detail_modal.dart';

import '../../../../data/models/appoiment_modal.dart';

class AppointmentCard extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback? onStatusChanged;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final isEmergency = widget.appointment.isEmergency;
    final isPending = widget.appointment.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isEmergency 
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with patient and emergency badge
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      widget.appointment.patientName.isNotEmpty 
                          ? widget.appointment.patientName[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.appointment.patientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isEmergency)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'EMERGENCY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dr. ${widget.appointment.doctorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(widget.appointment.status),
                ],
              ),
              const SizedBox(height: 16),
              
              // Appointment details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM dd, yyyy').format(widget.appointment.appointmentDate),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          widget.appointment.appointmentTime,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          widget.appointment.patientPhone,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        Icon(Icons.monetization_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'LKR ${AppointmentService.formatCurrency(widget.appointment.consultationFee.toInt())}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A4C93),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (widget.appointment.symptoms != null && widget.appointment.symptoms!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Symptoms/Reason:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.appointment.symptoms!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isPending) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUpdating ? null : () => _updateStatus('cancelled'),
                        icon: _isUpdating 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _updateStatus('upcoming'),
                        icon: _isUpdating 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _makePhoneCall(),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call Patient'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A4C93),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'PENDING';
        break;
      case 'upcoming':
        color = Colors.blue;
        label = 'CONFIRMED';
        break;
      case 'completed':
        color = Colors.green;
        label = 'COMPLETED';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'CANCELLED';
        break;
      default:
        color = Colors.grey;
        label = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppointmentDetailsModal(
        appointment: widget.appointment,
        isAdmin: true,
        onUpdateStatus: (status) => _updateStatus(status),
        onCall: () => _makePhoneCall(),
      ),
    );
  }

  void _showStatusUpdateDialog() {
    if (!mounted) return;
    
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
                _updateStatus('upcoming');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as Completed'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus('completed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Mark as Cancelled'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus('cancelled');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    if (!mounted) return;
    
    setState(() {
      _isUpdating = true;
    });

    try {
      final success = await AppointmentService.updateAppointmentStatus(
        widget.appointment.id, 
        newStatus,
      );
      
      if (!mounted) return;
      
      setState(() {
        _isUpdating = false;
      });

      if (success) {
        _showSnackBar(
          'Appointment status updated to $newStatus',
          Colors.green,
        );
        widget.onStatusChanged?.call();
      } else {
        _showSnackBar(
          'Error updating appointment status',
          Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUpdating = false;
      });
      
      _showSnackBar(
        'Error updating appointment status',
        Colors.red,
      );
    }
  }

  Future<void> _makePhoneCall() async {
    try {
      final success = await AppointmentService.makePhoneCall(
        widget.appointment.patientPhone,
      );
      
      if (!mounted) return;
      
      if (!success) {
        _showSnackBar(
          'Could not launch phone dialer',
          Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      _showSnackBar(
        'Could not launch phone dialer',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
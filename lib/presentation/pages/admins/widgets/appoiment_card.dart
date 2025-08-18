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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final isEmergency = widget.appointment.isEmergency;
    final isPending = widget.appointment.status == 'pending';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          margin: EdgeInsets.only(
            bottom: isTablet ? 20 : 16,
            left: isDesktop ? 8 : 0,
            right: isDesktop ? 8 : 0,
          ),
          elevation: isTablet ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            side: isEmergency 
                ? BorderSide(color: Colors.red, width: isTablet ? 3 : 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _showAppointmentDetails(context),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                children: [
                  // Header with patient and emergency badge
                  _buildHeader(isTablet, isDesktop, isEmergency),
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  // Appointment details
                  _buildAppointmentDetails(isTablet, isDesktop, constraints),
                  
                  if (widget.appointment.symptoms != null && 
                      widget.appointment.symptoms!.isNotEmpty) ...[
                    SizedBox(height: isTablet ? 16 : 12),
                    _buildSymptomsSection(isTablet),
                  ],
                  
                  // Action buttons
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildActionButtons(isPending, isTablet, isDesktop, constraints),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isTablet, bool isDesktop, bool isEmergency) {
    return Row(
      children: [
        CircleAvatar(
          radius: isTablet ? 30 : 25,
          backgroundColor: Colors.grey[300],
          child: Text(
            widget.appointment.patientName.isNotEmpty 
                ? widget.appointment.patientName[0].toUpperCase()
                : 'P',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 22 : 18,
            ),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.appointment.patientName,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEmergency)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Text(
                        'EMERGENCY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                'Dr. ${widget.appointment.doctorName}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        _buildStatusBadge(widget.appointment.status, isTablet),
      ],
    );
  }

  Widget _buildAppointmentDetails(bool isTablet, bool isDesktop, BoxConstraints constraints) {
    final shouldStack = constraints.maxWidth < 400 && !isTablet;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: shouldStack ? _buildStackedDetails(isTablet) : _buildRowDetails(isTablet),
    );
  }

  Widget _buildStackedDetails(bool isTablet) {
    return Column(
      children: [
        _buildDetailRow(
          Icons.calendar_today,
          DateFormat('EEEE, MMM dd, yyyy').format(widget.appointment.appointmentDate),
          isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        _buildDetailRow(
          Icons.access_time,
          widget.appointment.appointmentTime,
          isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        _buildDetailRow(
          Icons.phone,
          widget.appointment.patientPhone,
          isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 8),
        _buildDetailRow(
          Icons.monetization_on,
          'LKR ${AppointmentService.formatCurrency(widget.appointment.consultationFee.toInt())}',
          isTablet,
          isFee: true,
        ),
      ],
    );
  }

  Widget _buildRowDetails(bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailRow(
                Icons.calendar_today,
                DateFormat('EEEE, MMM dd, yyyy').format(widget.appointment.appointmentDate),
                isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 24 : 16),
            _buildDetailRow(
              Icons.access_time,
              widget.appointment.appointmentTime,
              isTablet,
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailRow(
                Icons.phone,
                widget.appointment.patientPhone,
                isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 24 : 16),
            _buildDetailRow(
              Icons.monetization_on,
              'LKR ${AppointmentService.formatCurrency(widget.appointment.consultationFee.toInt())}',
              isTablet,
              isFee: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isTablet, {bool isFee = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isTablet ? 20 : 16, color: Colors.grey[600]),
        SizedBox(width: isTablet ? 8 : 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: isFee ? FontWeight.bold : FontWeight.w500,
              color: isFee ? const Color(0xFF6A4C93) : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, size: isTablet ? 20 : 16, color: Colors.blue[700]),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Symptoms/Reason:',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            widget.appointment.symptoms!,
            style: TextStyle(fontSize: isTablet ? 16 : 14),
            maxLines: isTablet ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isPending, bool isTablet, bool isDesktop, BoxConstraints constraints) {
    final shouldStack = constraints.maxWidth < 300 && !isTablet;
    final buttonHeight = isTablet ? 48.0 : 40.0;
    
    if (shouldStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildButtonList(isPending, isTablet, buttonHeight),
      );
    }
    
    return Row(
      children: isPending ? _buildPendingButtons(isTablet, buttonHeight) : _buildActiveButtons(isTablet, buttonHeight),
    );
  }

  List<Widget> _buildButtonList(bool isPending, bool isTablet, double buttonHeight) {
    final buttons = isPending ? _buildPendingButtons(isTablet, buttonHeight, isStacked: true) : _buildActiveButtons(isTablet, buttonHeight, isStacked: true);
    final result = <Widget>[];
    
    for (int i = 0; i < buttons.length; i++) {
      if (buttons[i] is SizedBox) continue; // Skip spacers
      result.add(SizedBox(height: buttonHeight, child: buttons[i]));
      if (i < buttons.length - 1) {
        result.add(SizedBox(height: isTablet ? 12 : 8));
      }
    }
    
    return result;
  }

  List<Widget> _buildPendingButtons(bool isTablet, double buttonHeight, {bool isStacked = false}) {
    return [
      if (!isStacked) Expanded(
        child: SizedBox(
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: _isUpdating ? null : () => _updateStatus('cancelled'),
            icon: _isUpdating 
                ? SizedBox(
                    width: isTablet ? 20 : 16,
                    height: isTablet ? 20 : 16,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.close, size: isTablet ? 20 : 16),
            label: Text('Reject', style: TextStyle(fontSize: isTablet ? 16 : 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ) else OutlinedButton.icon(
        onPressed: _isUpdating ? null : () => _updateStatus('cancelled'),
        icon: _isUpdating 
            ? SizedBox(
                width: isTablet ? 20 : 16,
                height: isTablet ? 20 : 16,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.close, size: isTablet ? 20 : 16),
        label: Text('Reject', style: TextStyle(fontSize: isTablet ? 16 : 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
      ),
      if (!isStacked) SizedBox(width: isTablet ? 16 : 12),
      if (!isStacked) Expanded(
        child: SizedBox(
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateStatus('upcoming'),
            icon: _isUpdating 
                ? SizedBox(
                    width: isTablet ? 20 : 16,
                    height: isTablet ? 20 : 16,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.check, size: isTablet ? 20 : 16),
            label: Text('Approve', style: TextStyle(fontSize: isTablet ? 16 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ) else ElevatedButton.icon(
        onPressed: _isUpdating ? null : () => _updateStatus('upcoming'),
        icon: _isUpdating 
            ? SizedBox(
                width: isTablet ? 20 : 16,
                height: isTablet ? 20 : 16,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(Icons.check, size: isTablet ? 20 : 16),
        label: Text('Approve', style: TextStyle(fontSize: isTablet ? 16 : 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    ];
  }

  List<Widget> _buildActiveButtons(bool isTablet, double buttonHeight, {bool isStacked = false}) {
    return [
      if (!isStacked) Expanded(
        child: SizedBox(
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () => _makePhoneCall(),
            icon: Icon(Icons.phone, size: isTablet ? 20 : 16),
            label: Text('Call Patient', style: TextStyle(fontSize: isTablet ? 16 : 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
            ),
          ),
        ),
      ) else OutlinedButton.icon(
        onPressed: () => _makePhoneCall(),
        icon: Icon(Icons.phone, size: isTablet ? 20 : 16),
        label: Text('Call Patient', style: TextStyle(fontSize: isTablet ? 16 : 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
        ),
      ),
      if (!isStacked) SizedBox(width: isTablet ? 16 : 12),
      if (!isStacked) Expanded(
        child: SizedBox(
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () => _showStatusUpdateDialog(),
            icon: Icon(Icons.edit, size: isTablet ? 20 : 16),
            label: Text('Update', style: TextStyle(fontSize: isTablet ? 16 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4C93),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ) else ElevatedButton.icon(
        onPressed: () => _showStatusUpdateDialog(),
        icon: Icon(Icons.edit, size: isTablet ? 20 : 16),
        label: Text('Update', style: TextStyle(fontSize: isTablet ? 16 : 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A4C93),
          foregroundColor: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildStatusBadge(String status, bool isTablet) {
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
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
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
    
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Status',
          style: TextStyle(fontSize: isTablet ? 20 : 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: Text(
                'Mark as Upcoming',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              onTap: () {
                Navigator.pop(context);
                _updateStatus('upcoming');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                'Mark as Completed',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              onTap: () {
                Navigator.pop(context);
                _updateStatus('completed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: Text(
                'Mark as Cancelled',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
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
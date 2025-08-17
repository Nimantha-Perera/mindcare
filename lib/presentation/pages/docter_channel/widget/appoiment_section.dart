import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// You'll need to create these models or adjust according to your existing models
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final String patientId;
  final String patientName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final double consultationFee;
  final String? notes;
  final String? meetingLink;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.patientId,
    required this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.consultationFee,
    this.notes,
    this.meetingLink,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Unknown Doctor',
      doctorSpecialty: data['doctorSpecialty'] ?? 'General Practice',
      doctorImage: data['doctorImage'] ?? '',
      patientId: data['patientId'] ?? data['userId'] ?? '',
      patientName: data['patientName'] ?? 'Unknown Patient',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      appointmentTime: data['appointmentTime'] ?? '',
      status: data['status'] ?? 'upcoming',
      consultationFee: (data['consultationFee'] ?? 0).toDouble(),
      notes: data['notes'],
      meetingLink: data['meetingLink'],
    );
  }
}

class AppointmentSections extends StatefulWidget {
  const AppointmentSections({Key? key}) : super(key: key);

  @override
  State<AppointmentSections> createState() => _AppointmentSectionsState();
}

class _AppointmentSectionsState extends State<AppointmentSections>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 131, 131, 131),
          labelColor: const Color.fromARGB(255, 94, 94, 94),
          unselectedLabelColor: const Color.fromARGB(179, 194, 194, 194),
          labelStyle: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.schedule),
              text: 'Upcoming',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Completed',
            ),
            Tab(
              icon: Icon(Icons.cancel),
              text: 'Cancelled',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList('upcoming'),
          _buildAppointmentList('completed'),
          _buildAppointmentList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text('Please log in to view appointments'),
      );
    }

    // Option A: Simple query without orderBy (to avoid composite index)
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6A4C93),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading appointments',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data?.docs
                .map((doc) => Appointment.fromFirestore(doc))
                .toList() ??
            [];

        // Sort appointments in memory instead of using Firestore orderBy
        appointments.sort((a, b) {
          if (status == 'completed') {
            return b.appointmentDate.compareTo(a.appointmentDate); // Descending
          } else {
            return a.appointmentDate.compareTo(b.appointmentDate); // Ascending
          }
        });

        if (appointments.isEmpty) {
          return _buildEmptyState(status);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(appointments[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case 'upcoming':
        icon = Icons.schedule;
        title = 'No Upcoming Appointments';
        subtitle = 'Book an appointment with your doctor to get started';
        break;
      case 'completed':
        icon = Icons.check_circle_outline;
        title = 'No Completed Appointments';
        subtitle = 'Your completed appointments will appear here';
        break;
      case 'cancelled':
        icon = Icons.cancel_outlined;
        title = 'No Cancelled Appointments';
        subtitle = 'Your cancelled appointments will appear here';
        break;
      default:
        icon = Icons.event_note;
        title = 'No Appointments';
        subtitle = 'No appointments found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ),
          if (status == 'upcoming') ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to doctor list or booking page
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Book Appointment'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isUpcoming = appointment.status == 'upcoming';
    final isCompleted = appointment.status == 'completed';
    final isCancelled = appointment.status == 'cancelled';

    Color statusColor;
    if (isUpcoming) {
      statusColor = Colors.blue;
    } else if (isCompleted) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with doctor info
              Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 25 : 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: appointment.doctorImage.isNotEmpty
                        ? NetworkImage(appointment.doctorImage)
                        : const NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/mindcare-e9b55.firebasestorage.app/o/doctor-1295571_1280.png?alt=media&token=78b0acbb-a308-4d66-a326-3824a6eec953'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorSpecialty,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
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
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM dd, yyyy')
                              .format(appointment.appointmentDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment.appointmentTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LKR ${_formatCurrency(appointment.consultationFee.toInt())}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6A4C93),
                          ),
                        ),
                        if (appointment.notes != null &&
                            appointment.notes!.isNotEmpty) ...[
                          const Spacer(),
                          Icon(
                            Icons.note,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Has Notes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              if (isUpcoming) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelAppointment(appointment),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () => _rescheduleAppointment(appointment),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF6A4C93),
                    //       foregroundColor: Colors.white,
                    //     ),
                    //     child: const Text('Reschedule'),
                    //   ),
                    // ),
                    if (appointment.meetingLink != null &&
                        appointment.meetingLink!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _joinMeeting(appointment.meetingLink!),
                          icon: const Icon(Icons.video_call, size: 16),
                          label: const Text('Join'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppointmentDetailsModal(appointment: appointment),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.doctorName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateAppointmentStatus(appointment.id, 'cancelled');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(Appointment appointment) {
    // Navigate to reschedule page or show reschedule modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reschedule functionality coming soon!'),
        backgroundColor: Color(0xFF6A4C93),
      ),
    );
  }

  void _joinMeeting(String meetingLink) {
    // Launch meeting URL or show meeting details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining meeting: $meetingLink'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $status successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCurrency(int amount) {
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}

class AppointmentDetailsModal extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsModal({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
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
                  // Doctor info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: appointment.doctorImage.isNotEmpty
                            ? NetworkImage(appointment.doctorImage)
                            : const NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/mindcare-e9b55.firebasestorage.app/o/doctor-1295571_1280.png?alt=media&token=78b0acbb-a308-4d66-a326-3824a6eec953'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment.doctorSpecialty,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Appointment details
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('EEEE, MMMM dd, yyyy')
                        .format(appointment.appointmentDate),
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Time',
                    appointment.appointmentTime,
                  ),
                  _buildDetailRow(
                    Icons.monetization_on,
                    'Consultation Fee',
                    'LKR ${_formatCurrency(appointment.consultationFee.toInt())}',
                  ),
                  _buildDetailRow(
                    Icons.info_outline,
                    'Status',
                    appointment.status.toUpperCase(),
                  ),

                  if (appointment.notes != null &&
                      appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.note,
                      'Notes',
                      appointment.notes!,
                    ),
                  ],

                  if (appointment.meetingLink != null &&
                      appointment.meetingLink!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.video_call,
                      'Meeting Link',
                      appointment.meetingLink!,
                      isLink: true,
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLink ? const Color(0xFF6A4C93) : Colors.black87,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare/data/models/appoiment_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get appointments stream with optional status filter
  static Stream<QuerySnapshot> getAppointmentsStream({String? status}) {
    Query query = _firestore.collection('appointments');
    
    if (status != null && status != 'all') {
      // This requires composite index: status + appointmentDate
      query = query
          .where('status', isEqualTo: status)
          .orderBy('appointmentDate', descending: false);
    } else {
      // This requires single field index: appointmentDate
      query = query.orderBy('appointmentDate', descending: false);
    }
    
    return query.snapshots();
  }

  /// Get recent appointments for activity feed
  static Stream<QuerySnapshot> getRecentAppointmentsStream({int limit = 5}) {
    // This requires single field index: createdAt (descending)
    return _firestore
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Update appointment status
  static Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  /// Delete appointment
  static Future<bool> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }

  /// Create new appointment
  static Future<String?> createAppointment(Appointment appointment) async {
    try {
      final docRef = await _firestore.collection('appointments').add({
        ...appointment.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      return null;
    }
  }

  /// Get appointment statistics - optimized version
  static Future<Map<String, dynamic>> getAppointmentStatistics() async {
    try {
      // Get all appointments without ordering to avoid index requirements
      final snapshot = await _firestore.collection('appointments').get();
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
      
      final stats = <String, int>{};
      double revenue = 0.0;
      
      for (final appointment in appointments) {
        stats[appointment.status] = (stats[appointment.status] ?? 0) + 1;
        if (appointment.status == 'completed') {
          revenue += appointment.consultationFee;
        }
      }
      
      return {
        'stats': stats,
        'revenue': revenue,
      };
    } catch (e) {
      print('Error loading statistics: $e');
      return {
        'stats': <String, int>{},
        'revenue': 0.0,
      };
    }
  }

  /// Alternative method for filtered appointments with better performance
  static Stream<QuerySnapshot> getFilteredAppointmentsStream({
    String? status,
    String? doctorName,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    Query query = _firestore.collection('appointments');
    
    // Apply filters in order of selectivity
    if (status != null && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }
    
    if (doctorName != null && doctorName != 'all') {
      query = query.where('doctorName', isEqualTo: doctorName);
    }
    
    if (dateFrom != null) {
      query = query.where('appointmentDate', isGreaterThanOrEqualTo: dateFrom);
    }
    
    if (dateTo != null) {
      query = query.where('appointmentDate', isLessThanOrEqualTo: dateTo);
    }
    
    // Order by appointment date
    query = query.orderBy('appointmentDate', descending: false);
    
    return query.snapshots();
  }

  /// Make phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      }
      return false;
    } catch (e) {
      print('Error making call: $e');
      return false;
    }
  }

  /// Filter appointments based on criteria (client-side filtering)
  static List<Appointment> filterAppointments(
    List<Appointment> appointments, {
    String searchQuery = '',
    String doctorFilter = 'all',
    DateTime? dateFilter,
    bool emergencyOnly = false,
  }) {
    return appointments.where((appointment) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        if (!appointment.patientName.toLowerCase().contains(searchLower) &&
            !appointment.doctorName.toLowerCase().contains(searchLower) &&
            !appointment.id.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Doctor filter
      if (doctorFilter != 'all' && appointment.doctorName != doctorFilter) {
        return false;
      }

      // Date filter
      if (dateFilter != null) {
        final appointmentDate = DateTime(
          appointment.appointmentDate.year,
          appointment.appointmentDate.month,
          appointment.appointmentDate.day,
        );
        final filterDate = DateTime(
          dateFilter.year,
          dateFilter.month,
          dateFilter.day,
        );
        if (!appointmentDate.isAtSameMomentAs(filterDate)) {
          return false;
        }
      }

      // Emergency filter
      if (emergencyOnly && !appointment.isEmergency) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Format currency with commas
  static String formatCurrency(int amount) {
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final int patientAge;
  final String patientGender;
  final String patientAddress;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;
  final double consultationFee;
  final String? symptoms;
  final bool isEmergency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.patientAge,
    required this.patientGender,
    required this.patientAddress,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.consultationFee,
    this.symptoms,
    this.isEmergency = false,
    this.createdAt,
    this.updatedAt,
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
      patientPhone: data['patientPhone'] ?? '',
      patientEmail: data['patientEmail'] ?? '',
      patientAge: data['patientAge'] ?? 0,
      patientGender: data['patientGender'] ?? '',
      patientAddress: data['patientAddress'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      appointmentTime: data['appointmentTime'] ?? '',
      status: data['status'] ?? 'upcoming',
      consultationFee: (data['consultationFee'] ?? 0).toDouble(),
      symptoms: data['symptoms'],
      isEmergency: data['isEmergency'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientEmail': patientEmail,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'patientAddress': patientAddress,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'appointmentTime': appointmentTime,
      'status': status,
      'consultationFee': consultationFee,
      'symptoms': symptoms,
      'isEmergency': isEmergency,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
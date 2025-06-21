import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.rating,
    required super.reviews,
    required super.experience,
    required super.isOnline,
    required super.consultationFee,
    required super.profileImage,
    required super.about,
    required super.nextAvailable,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      experience: data['experience'] ?? 0,
      isOnline: data['isOnline'] ?? false,
      consultationFee: data['consultationFee'] ?? 0,
      profileImage: data['profileImage'] ?? '',
      about: data['about'] ?? '',
      nextAvailable: data['nextAvailable'] != null 
          ? (data['nextAvailable'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory DoctorModel.fromEntity(Doctor doctor) {
    return DoctorModel(
      id: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      rating: doctor.rating,
      reviews: doctor.reviews,
      experience: doctor.experience,
      isOnline: doctor.isOnline,
      consultationFee: doctor.consultationFee,
      profileImage: doctor.profileImage,
      about: doctor.about,
      nextAvailable: doctor.nextAvailable,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'reviews': reviews,
      'experience': experience,
      'isOnline': isOnline,
      'consultationFee': consultationFee,
      'profileImage': profileImage,
      'about': about,
      'nextAvailable': Timestamp.fromDate(nextAvailable),
    };
  }

  Doctor toEntity() {
    return Doctor(
      id: id,
      name: name,
      specialty: specialty,
      rating: rating,
      reviews: reviews,
      experience: experience,
      isOnline: isOnline,
      consultationFee: consultationFee,
      profileImage: profileImage,
      about: about,
      nextAvailable: nextAvailable,
    );
  }
}
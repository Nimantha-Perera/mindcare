import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare/domain/models/doctor_modal.dart';


abstract class FirestoreDoctorDataSource {
  Stream<List<DoctorModel>> getAllDoctors();
  Stream<List<DoctorModel>> getDoctorsBySpecialty(String specialty);
  Stream<List<DoctorModel>> getOnlineDoctors();
  Stream<List<DoctorModel>> getDoctorsWithFilters({
    String? specialty,
    bool? isOnlineOnly,
  });
  Future<List<DoctorModel>> getUserDoctors(String userId);
  Future<void> addToUserDoctors(String userId, String doctorId);
  Future<void> removeFromUserDoctors(String userId, String doctorId);
  Future<bool> isDoctorInUserList(String userId, String doctorId);
}

class FirestoreDoctorDataSourceImpl implements FirestoreDoctorDataSource {
  static const String _doctorsCollection = 'doctors';
  static const String _userDoctorsCollection = 'user_doctors';
  
  final FirebaseFirestore _firestore;

  FirestoreDoctorDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<DoctorModel>> getAllDoctors() {
    return _firestore
        .collection(_doctorsCollection)
        .snapshots()
        .map(_mapQuerySnapshotToDoctorList);
  }

  @override
  Stream<List<DoctorModel>> getDoctorsBySpecialty(String specialty) {
    return _firestore
        .collection(_doctorsCollection)
        .where('specialty', isEqualTo: specialty)
        .snapshots()
        .map(_mapQuerySnapshotToDoctorList);
  }

  @override
  Stream<List<DoctorModel>> getOnlineDoctors() {
    return _firestore
        .collection(_doctorsCollection)
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map(_mapQuerySnapshotToDoctorList);
  }

  @override
  Stream<List<DoctorModel>> getDoctorsWithFilters({
    String? specialty,
    bool? isOnlineOnly,
  }) {
    Query query = _firestore.collection(_doctorsCollection);

    if (specialty != null && specialty != 'All') {
      query = query.where('specialty', isEqualTo: specialty);
    }

    if (isOnlineOnly == true) {
      query = query.where('isOnline', isEqualTo: true);
    }

    return query.snapshots().map(_mapQuerySnapshotToDoctorList);
  }

  @override
  Future<List<DoctorModel>> getUserDoctors(String userId) async {
    try {
      final userDocRef = _firestore.collection(_userDoctorsCollection).doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) return [];

      final data = userDoc.data();
      final doctorIds = List<String>.from(data?['doctorIds'] ?? []);

      if (doctorIds.isEmpty) return [];

      // Split into chunks of 10 for Firestore 'in' query limitation
      final chunks = <List<String>>[];
      for (var i = 0; i < doctorIds.length; i += 10) {
        chunks.add(doctorIds.sublist(
          i, 
          i + 10 > doctorIds.length ? doctorIds.length : i + 10
        ));
      }

      final List<DoctorModel> doctors = [];
      for (final chunk in chunks) {
        final querySnapshot = await _firestore
            .collection(_doctorsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        doctors.addAll(_mapQuerySnapshotToDoctorList(querySnapshot));
      }

      return doctors;
    } catch (e) {
      throw Exception('Failed to get user doctors: $e');
    }
  }

  @override
  Future<void> addToUserDoctors(String userId, String doctorId) async {
    try {
      final userDocRef = _firestore.collection(_userDoctorsCollection).doc(userId);
      
      await userDocRef.set({
        'doctorIds': FieldValue.arrayUnion([doctorId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add doctor to user list: $e');
    }
  }

  @override
  Future<void> removeFromUserDoctors(String userId, String doctorId) async {
    try {
      final userDocRef = _firestore.collection(_userDoctorsCollection).doc(userId);
      
      await userDocRef.update({
        'doctorIds': FieldValue.arrayRemove([doctorId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove doctor from user list: $e');
    }
  }

  @override
  Future<bool> isDoctorInUserList(String userId, String doctorId) async {
    try {
      final userDocRef = _firestore.collection(_userDoctorsCollection).doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) return false;

      final data = userDoc.data();
      final doctorIds = List<String>.from(data?['doctorIds'] ?? []);
      
      return doctorIds.contains(doctorId);
    } catch (e) {
      throw Exception('Failed to check if doctor is in user list: $e');
    }
  }

  List<DoctorModel> _mapQuerySnapshotToDoctorList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => DoctorModel.fromFirestore(doc))
        .toList();
  }
}
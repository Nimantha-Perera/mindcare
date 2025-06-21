import '../entities/doctor.dart';

abstract class DoctorRepository {
  Stream<List<Doctor>> getAllDoctors();
  Stream<List<Doctor>> getDoctorsBySpecialty(String specialty);
  Stream<List<Doctor>> getOnlineDoctors();
  Stream<List<Doctor>> getDoctorsWithFilters({
    String? specialty,
    bool? isOnlineOnly,
  });
  Future<List<Doctor>> getUserDoctors(String userId);
  Future<void> addToUserDoctors(String userId, String doctorId);
  Future<void> removeFromUserDoctors(String userId, String doctorId);
  Future<bool> isDoctorInUserList(String userId, String doctorId);
}
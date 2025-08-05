import 'package:mindcare/data/datasources/firestore_doctore_datasource.dart';
import 'package:mindcare/domain/repositories/doctor_repo.dart';

import '../../domain/entities/doctor.dart';


class DoctorRepositoryImpl implements DoctorRepository {
  final FirestoreDoctorDataSource _dataSource;

  DoctorRepositoryImpl(this._dataSource);

  @override
  Stream<List<Doctor>> getAllDoctors() {
    return _dataSource.getAllDoctors().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Doctor>> getDoctorsBySpecialty(String specialty) {
    return _dataSource.getDoctorsBySpecialty(specialty).map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Doctor>> getOnlineDoctors() {
    return _dataSource.getOnlineDoctors().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Doctor>> getDoctorsWithFilters({
    String? specialty,
    bool? isOnlineOnly,
  }) {
    return _dataSource.getDoctorsWithFilters(
      specialty: specialty,
      isOnlineOnly: isOnlineOnly,
    ).map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<List<Doctor>> getUserDoctors(String userId) async {
    final models = await _dataSource.getUserDoctors(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addToUserDoctors(String userId, String doctorId) {
    return _dataSource.addToUserDoctors(userId, doctorId);
  }

  @override
  Future<void> removeFromUserDoctors(String userId, String doctorId) {
    return _dataSource.removeFromUserDoctors(userId, doctorId);
  }

  @override
  Future<bool> isDoctorInUserList(String userId, String doctorId) {
    return _dataSource.isDoctorInUserList(userId, doctorId);
  }
}
import 'package:mindcare/domain/repositories/doctor_repo.dart';

import '../entities/doctor.dart';

class GetUserDoctorsUseCase {
  final DoctorRepository _repository;

  GetUserDoctorsUseCase(this._repository);

  Future<List<Doctor>> call(String userId) {
    return _repository.getUserDoctors(userId);
  }
}

class AddToUserDoctorsUseCase {
  final DoctorRepository _repository;

  AddToUserDoctorsUseCase(this._repository);

  Future<void> call(String userId, String doctorId) {
    return _repository.addToUserDoctors(userId, doctorId);
  }
}

class RemoveFromUserDoctorsUseCase {
  final DoctorRepository _repository;

  RemoveFromUserDoctorsUseCase(this._repository);

  Future<void> call(String userId, String doctorId) {
    return _repository.removeFromUserDoctors(userId, doctorId);
  }
}

class CheckDoctorInUserListUseCase {
  final DoctorRepository _repository;

  CheckDoctorInUserListUseCase(this._repository);

  Future<bool> call(String userId, String doctorId) {
    return _repository.isDoctorInUserList(userId, doctorId);
  }
}
import 'package:mindcare/domain/repositories/doctor_repo.dart';

import '../entities/doctor.dart';

class GetDoctorsUseCase {
  final DoctorRepository _repository;

  GetDoctorsUseCase(this._repository);

  Stream<List<Doctor>> call({
    String? specialty,
    bool? isOnlineOnly,
  }) {
    return _repository.getDoctorsWithFilters(
      specialty: specialty,
      isOnlineOnly: isOnlineOnly,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:mindcare/data/datasources/firestore_doctore_datasource.dart';
import 'package:mindcare/data/repositories/doctor_repo_impl.dart';
import 'package:mindcare/domain/repositories/doctor_repo.dart';
import 'package:mindcare/domain/usecases/get_doctors_usecase.dart';
import 'package:mindcare/domain/usecases/manage_user_doctors_usecase.dart';
import 'package:mindcare/presentation/cubit/doctor_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {

  sl.registerFactory(
    () => DoctorCubit(
      getDoctorsUseCase: sl(),
      getUserDoctorsUseCase: sl(),
      addToUserDoctorsUseCase: sl(),
      removeFromUserDoctorsUseCase: sl(),
      checkDoctorInUserListUseCase: sl(),
    ),
  );


  sl.registerLazySingleton(() => GetDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => AddToUserDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromUserDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => CheckDoctorInUserListUseCase(sl()));


  sl.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<FirestoreDoctorDataSource>(
    () => FirestoreDoctorDataSourceImpl(firestore: sl()),
  );


  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}
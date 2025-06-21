import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/manage_user_doctors_usecase.dart';

// States
abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<Doctor> doctors;
  final List<Doctor> userDoctors;
  final String selectedSpecialty;
  final bool isOnlineOnly;

  const DoctorLoaded({
    required this.doctors,
    required this.userDoctors,
    required this.selectedSpecialty,
    required this.isOnlineOnly,
  });

  @override
  List<Object?> get props => [doctors, userDoctors, selectedSpecialty, isOnlineOnly];

  DoctorLoaded copyWith({
    List<Doctor>? doctors,
    List<Doctor>? userDoctors,
    String? selectedSpecialty,
    bool? isOnlineOnly,
  }) {
    return DoctorLoaded(
      doctors: doctors ?? this.doctors,
      userDoctors: userDoctors ?? this.userDoctors,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      isOnlineOnly: isOnlineOnly ?? this.isOnlineOnly,
    );
  }
}

class DoctorError extends DoctorState {
  final String message;

  const DoctorError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DoctorCubit extends Cubit<DoctorState> {
  final GetDoctorsUseCase _getDoctorsUseCase;
  final GetUserDoctorsUseCase _getUserDoctorsUseCase;
  final AddToUserDoctorsUseCase _addToUserDoctorsUseCase;
  final RemoveFromUserDoctorsUseCase _removeFromUserDoctorsUseCase;
  final CheckDoctorInUserListUseCase _checkDoctorInUserListUseCase;

  StreamSubscription<List<Doctor>>? _doctorsSubscription;
  String _currentUserId = 'default_user'; // In real app, get from auth service

  DoctorCubit({
    required GetDoctorsUseCase getDoctorsUseCase,
    required GetUserDoctorsUseCase getUserDoctorsUseCase,
    required AddToUserDoctorsUseCase addToUserDoctorsUseCase,
    required RemoveFromUserDoctorsUseCase removeFromUserDoctorsUseCase,
    required CheckDoctorInUserListUseCase checkDoctorInUserListUseCase,
  })  : _getDoctorsUseCase = getDoctorsUseCase,
        _getUserDoctorsUseCase = getUserDoctorsUseCase,
        _addToUserDoctorsUseCase = addToUserDoctorsUseCase,
        _removeFromUserDoctorsUseCase = removeFromUserDoctorsUseCase,
        _checkDoctorInUserListUseCase = checkDoctorInUserListUseCase,
        super(DoctorInitial());

  void loadDoctors({
    String specialty = 'All',
    bool isOnlineOnly = false,
  }) async {
    emit(DoctorLoading());

    try {
      // Cancel previous subscription
      await _doctorsSubscription?.cancel();

      // Load user doctors
      final userDoctors = await _getUserDoctorsUseCase(_currentUserId);

      // Subscribe to doctors stream
      _doctorsSubscription = _getDoctorsUseCase(
        specialty: specialty == 'All' ? null : specialty,
        isOnlineOnly: isOnlineOnly,
      ).listen(
        (doctors) {
          emit(DoctorLoaded(
            doctors: doctors,
            userDoctors: userDoctors,
            selectedSpecialty: specialty,
            isOnlineOnly: isOnlineOnly,
          ));
        },
        onError: (error) {
          emit(DoctorError('Failed to load doctors: $error'));
        },
      );
    } catch (e) {
      emit(DoctorError('Failed to load doctors: $e'));
    }
  }

  void filterDoctors({
    String? specialty,
    bool? isOnlineOnly,
  }) {
    final currentState = state;
    if (currentState is DoctorLoaded) {
      loadDoctors(
        specialty: specialty ?? currentState.selectedSpecialty,
        isOnlineOnly: isOnlineOnly ?? currentState.isOnlineOnly,
      );
    }
  }

  Future<void> addDoctorToUser(String doctorId) async {
    try {
      await _addToUserDoctorsUseCase(_currentUserId, doctorId);
      await refreshUserDoctors();
    } catch (e) {
      emit(DoctorError('Failed to add doctor: $e'));
    }
  }

  Future<void> removeDoctorFromUser(String doctorId) async {
    try {
      await _removeFromUserDoctorsUseCase(_currentUserId, doctorId);
      await refreshUserDoctors();
    } catch (e) {
      emit(DoctorError('Failed to remove doctor: $e'));
    }
  }

  Future<bool> isDoctorInUserList(String doctorId) async {
    try {
      return await _checkDoctorInUserListUseCase(_currentUserId, doctorId);
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshUserDoctors() async {
    final currentState = state;
    if (currentState is DoctorLoaded) {
      try {
        final userDoctors = await _getUserDoctorsUseCase(_currentUserId);
        emit(currentState.copyWith(userDoctors: userDoctors));
      } catch (e) {
        emit(DoctorError('Failed to refresh user doctors: $e'));
      }
    }
  }

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  @override
  Future<void> close() {
    _doctorsSubscription?.cancel();
    return super.close();
  }
}
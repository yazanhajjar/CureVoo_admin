import 'package:equatable/equatable.dart';
import '../../models/admin_users/admin_doctor_item.dart';
import '../../models/admin_users/admin_patient_item.dart';

enum AdminUsersStatus { initial, submitting, success, failure }

class AdminUsersState extends Equatable {
  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.message,
    this.validationErrors = const <String, String>{},
    this.isLoadingDoctors = false,
    this.isLoadingPatients = false,
    this.doctors = const <AdminDoctorItem>[],
    this.patients = const <AdminPatientItem>[],
  });

  final AdminUsersStatus status;
  final String? message;
  final Map<String, String> validationErrors;
  final bool isLoadingDoctors;
  final bool isLoadingPatients;
  final List<AdminDoctorItem> doctors;
  final List<AdminPatientItem> patients;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    String? message,
    bool clearMessage = false,
    Map<String, String>? validationErrors,
    bool clearValidationErrors = false,
    bool? isLoadingDoctors,
    bool? isLoadingPatients,
    List<AdminDoctorItem>? doctors,
    List<AdminPatientItem>? patients,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      validationErrors: clearValidationErrors ? const <String, String>{} : (validationErrors ?? this.validationErrors),
      isLoadingDoctors: isLoadingDoctors ?? this.isLoadingDoctors,
      isLoadingPatients: isLoadingPatients ?? this.isLoadingPatients,
      doctors: doctors ?? this.doctors,
      patients: patients ?? this.patients,
    );
  }

  @override
  List<Object?> get props => [status, message, validationErrors, isLoadingDoctors, isLoadingPatients, doctors, patients];
}

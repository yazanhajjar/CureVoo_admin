import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/admin_users/admin_doctor_requests.dart';
import '../../models/admin_users/admin_patient_requests.dart';
import '../../repos/admin_users_repo.dart';
import '../../repos/api_client.dart';
import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit(this._repo) : super(const AdminUsersState());

  final AdminUsersRepo _repo;

  Future<void> loadDoctors() async {
    emit(state.copyWith(isLoadingDoctors: true, clearMessage: true));
    try {
      final doctors = await _repo.fetchDoctors();
      emit(state.copyWith(isLoadingDoctors: false, doctors: doctors));
    } on ApiException catch (e) {
      emit(state.copyWith(isLoadingDoctors: false, message: e.message));
    } catch (_) {
      emit(state.copyWith(isLoadingDoctors: false, message: 'Failed to load doctors.'));
    }
  }

  Future<void> loadPatients() async {
    emit(state.copyWith(isLoadingPatients: true, clearMessage: true));
    try {
      final patients = await _repo.fetchPatients();
      emit(state.copyWith(isLoadingPatients: false, patients: patients));
    } on ApiException catch (e) {
      emit(state.copyWith(isLoadingPatients: false, message: e.message));
    } catch (_) {
      emit(state.copyWith(isLoadingPatients: false, message: 'Failed to load patients.'));
    }
  }

  Future<void> createDoctor(CreateAdminDoctorRequest request) async {
    final ok = await _run(() => _repo.createDoctor(request), successMessage: 'Doctor created successfully.');
    if (!ok) return;
    await loadDoctors();
  }

  Future<void> updateDoctor(String userId, UpdateAdminDoctorRequest request) async {
    final ok = await _run(() => _repo.updateDoctor(userId, request), successMessage: 'Doctor updated successfully.');
    if (!ok) return;
    _patchDoctorInState(userId, request);
    unawaited(loadDoctors());
  }

  Future<void> deleteDoctor(String userId) async {
    final ok = await _run(() => _repo.deleteDoctor(userId), successMessage: 'Doctor deleted successfully.');
    if (!ok) return;
    await loadDoctors();
  }

  Future<void> createPatient(CreateAdminPatientRequest request) async {
    final ok = await _run(() => _repo.createPatient(request), successMessage: 'Patient created successfully.');
    if (!ok) return;
    await loadPatients();
  }

  Future<void> updatePatient(String userId, UpdateAdminPatientRequest request) async {
    final ok = await _run(() => _repo.updatePatient(userId, request), successMessage: 'Patient updated successfully.');
    if (!ok) return;
    _patchPatientInState(userId, request);
    unawaited(loadPatients());
  }

  Future<void> deletePatient(String userId) async {
    final ok = await _run(() => _repo.deletePatient(userId), successMessage: 'Patient deleted successfully.');
    if (!ok) return;
    await loadPatients();
  }

  Future<bool> _run(Future<void> Function() action, {required String successMessage}) async {
    emit(state.copyWith(status: AdminUsersStatus.submitting, clearMessage: true, clearValidationErrors: true));
    try {
      await action();
      emit(state.copyWith(status: AdminUsersStatus.success, message: successMessage, clearValidationErrors: true));
      return true;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          message: e.message,
          validationErrors: _normalizeValidationErrors(e.details),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AdminUsersStatus.failure, message: 'Operation failed.', clearValidationErrors: true));
    }
    emit(state.copyWith(status: AdminUsersStatus.initial));
    return false;
  }

  Map<String, String> _normalizeValidationErrors(dynamic details) {
    if (details == null) return const <String, String>{};
    final out = <String, String>{};
    if (details is Map) {
      for (final entry in details.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          final msg = value.map((e) => e.toString()).join(', ');
          if (msg.isNotEmpty) out[key] = msg;
        } else if (value != null) {
          final msg = value.toString();
          if (msg.isNotEmpty) out[key] = msg;
        }
      }
      return out;
    }
    if (details is List) {
      for (final item in details) {
        if (item is Map) {
          final field = (item['field'] ?? item['path'] ?? item['key'] ?? '').toString().trim();
          final msg = (item['message'] ?? item['msg'] ?? item['error'] ?? '').toString().trim();
          if (field.isNotEmpty && msg.isNotEmpty) {
            out[field] = msg;
          }
        }
      }
    }
    return out;
  }

  void _patchDoctorInState(String userId, UpdateAdminDoctorRequest request) {
    final patched = state.doctors.map((doctor) {
      if (doctor.id != userId) return doctor;
      final raw = Map<String, dynamic>.from(doctor.raw);
      final profile = raw['doctorProfile'] is Map
          ? Map<String, dynamic>.from(raw['doctorProfile'] as Map)
          : <String, dynamic>{};
      if (request.fullName != null) {
        profile['fullName'] = request.fullName;
      }
      if (request.phoneNumber != null) {
        raw['phoneNumber'] = request.phoneNumber;
      }
      if (request.age != null) {
        raw['age'] = request.age;
      }
      if (request.specialization != null) {
        profile['specialization'] = request.specialization;
      }
      if (request.workingAt != null) {
        profile['workingAt'] = request.workingAt;
      }
      if (request.location != null) {
        profile['location'] = request.location;
      }
      if (request.languages != null) {
        profile['languages'] = request.languages;
      }
      if (request.qualifications != null) {
        profile['qualifications'] = request.qualifications;
      }
      if (request.experience != null) {
        profile['experience'] = request.experience;
      }
      if (request.bio != null) {
        profile['bio'] = request.bio;
      }
      if (request.photoUrl != null) {
        profile['photoUrl'] = request.photoUrl;
      }
      if (request.consultationFee != null) {
        profile['consultationFee'] = request.consultationFee;
      }
      if (request.isActive != null) {
        profile['isActive'] = request.isActive;
      }
      raw['doctorProfile'] = profile;
      return doctor.copyWith(
        fullName: request.fullName,
        phoneNumber: request.phoneNumber,
        specialization: request.specialization,
        location: request.location,
        isActive: request.isActive,
        raw: raw,
      );
    }).toList(growable: false);
    emit(state.copyWith(doctors: patched));
  }

  void _patchPatientInState(String userId, UpdateAdminPatientRequest request) {
    final patched = state.patients.map((patient) {
      if (patient.id != userId) return patient;
      final raw = Map<String, dynamic>.from(patient.raw);
      final profile = raw['patientProfile'] is Map
          ? Map<String, dynamic>.from(raw['patientProfile'] as Map)
          : <String, dynamic>{};
      if (request.fullName != null) {
        profile['fullName'] = request.fullName;
      }
      if (request.phoneNumber != null) {
        profile['phoneNumber'] = request.phoneNumber;
      }
      if (request.age != null) {
        profile['age'] = request.age;
      }
      if (request.sex != null) {
        profile['sex'] = request.sex;
      }
      if (request.location != null) {
        profile['location'] = request.location;
      }
      raw['patientProfile'] = profile;
      return patient.copyWith(
        fullName: request.fullName,
        phoneNumber: request.phoneNumber,
        age: request.age,
        sex: request.sex,
        location: request.location,
        raw: raw,
      );
    }).toList(growable: false);
    emit(state.copyWith(patients: patched));
  }
}

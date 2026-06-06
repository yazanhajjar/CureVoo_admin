import 'package:curevoo_admin/cubits/admin_users/admin_users_cubit.dart';
import 'package:curevoo_admin/models/admin_users/admin_doctor_item.dart';
import 'package:curevoo_admin/models/admin_users/admin_doctor_requests.dart';
import 'package:curevoo_admin/models/admin_users/admin_patient_item.dart';
import 'package:curevoo_admin/models/admin_users/admin_patient_requests.dart';
import 'package:curevoo_admin/repos/admin_users_repo.dart';
import 'package:curevoo_admin/repos/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminUsersRepo extends AdminUsersRepo {
  _FakeAdminUsersRepo() : super(ApiClient());

  bool shouldFailUpdateDoctor = false;
  bool shouldFailUpdatePatient = false;
  int fetchDoctorsCalls = 0;
  int fetchPatientsCalls = 0;
  List<AdminDoctorItem> doctors = const <AdminDoctorItem>[];
  List<AdminPatientItem> patients = const <AdminPatientItem>[];

  @override
  Future<List<AdminDoctorItem>> fetchDoctors() async {
    fetchDoctorsCalls += 1;
    return doctors;
  }

  @override
  Future<List<AdminPatientItem>> fetchPatients() async {
    fetchPatientsCalls += 1;
    return patients;
  }

  @override
  Future<void> updateDoctor(String userId, UpdateAdminDoctorRequest request) async {
    if (shouldFailUpdateDoctor) {
      throw ApiException('Doctor update failed');
    }
    doctors = doctors
        .map((doctor) {
          if (doctor.id != userId) return doctor;
          final raw = Map<String, dynamic>.from(doctor.raw);
          final profile = raw['doctorProfile'] is Map
              ? Map<String, dynamic>.from(raw['doctorProfile'] as Map)
              : <String, dynamic>{};
          if (request.fullName != null) profile['fullName'] = request.fullName;
          raw['doctorProfile'] = profile;
          return doctor.copyWith(fullName: request.fullName, raw: raw);
        })
        .toList(growable: false);
  }

  @override
  Future<void> updatePatient(String userId, UpdateAdminPatientRequest request) async {
    if (shouldFailUpdatePatient) {
      throw ApiException('Patient update failed');
    }
    patients = patients
        .map((patient) {
          if (patient.id != userId) return patient;
          final raw = Map<String, dynamic>.from(patient.raw);
          final profile = raw['patientProfile'] is Map
              ? Map<String, dynamic>.from(raw['patientProfile'] as Map)
              : <String, dynamic>{};
          if (request.fullName != null) profile['fullName'] = request.fullName;
          raw['patientProfile'] = profile;
          return patient.copyWith(fullName: request.fullName, raw: raw);
        })
        .toList(growable: false);
  }
}

void main() {
  test('updateDoctor patches row immediately and refreshes doctors list', () async {
    final repo = _FakeAdminUsersRepo();
    repo.doctors = <AdminDoctorItem>[
      const AdminDoctorItem(
        id: 'd1',
        fullName: 'Doctor One',
        email: 'doctor1@example.com',
        raw: <String, dynamic>{'doctorProfile': <String, dynamic>{'fullName': 'Doctor One'}},
      ),
    ];
    final cubit = AdminUsersCubit(repo);
    await cubit.loadDoctors();

    await cubit.updateDoctor(
      'd1',
      const UpdateAdminDoctorRequest(fullName: 'Doctor One Updated'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.doctors.first.fullName, 'Doctor One Updated');
    expect(repo.fetchDoctorsCalls, greaterThanOrEqualTo(2));
    await cubit.close();
  });

  test('updatePatient patches row immediately and refreshes patients list', () async {
    final repo = _FakeAdminUsersRepo();
    repo.patients = <AdminPatientItem>[
      const AdminPatientItem(
        id: 'p1',
        fullName: 'Patient One',
        email: 'patient1@example.com',
        raw: <String, dynamic>{'patientProfile': <String, dynamic>{'fullName': 'Patient One'}},
      ),
    ];
    final cubit = AdminUsersCubit(repo);
    await cubit.loadPatients();

    await cubit.updatePatient(
      'p1',
      const UpdateAdminPatientRequest(fullName: 'Patient One Updated'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.patients.first.fullName, 'Patient One Updated');
    expect(repo.fetchPatientsCalls, greaterThanOrEqualTo(2));
    await cubit.close();
  });
}

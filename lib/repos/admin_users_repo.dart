import '../constants/api_constants.dart';
import '../models/admin_users/admin_doctor_item.dart';
import '../models/admin_users/admin_doctor_requests.dart';
import '../models/admin_users/admin_patient_item.dart';
import '../models/admin_users/admin_patient_requests.dart';
import 'api_client.dart';

class AdminUsersRepo {
  AdminUsersRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminDoctorItem>> fetchDoctors() async {
    final res = await _apiClient.get(ApiConstants.adminDoctors);
    final data = res['data'];
    final raw = (data is Map<String, dynamic> ? data['items'] : null) ?? res['doctors'] ?? res['items'] ?? data ?? res;
    if (raw is List) {
      return raw
          .map((e) => AdminDoctorItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }
    return const <AdminDoctorItem>[];
  }

  Future<void> createDoctor(CreateAdminDoctorRequest request) async {
    await _apiClient.post(ApiConstants.adminDoctors, body: request.toJson());
  }

  Future<void> updateDoctor(String userId, UpdateAdminDoctorRequest request) async {
    await _apiClient.put('${ApiConstants.adminDoctors}/$userId', body: request.toJson());
  }

  Future<void> deleteDoctor(String userId) async {
    await _apiClient.delete('${ApiConstants.adminDoctors}/$userId');
  }

  Future<void> createPatient(CreateAdminPatientRequest request) async {
    await _apiClient.post(ApiConstants.adminPatients, body: request.toJson());
  }

  Future<void> updatePatient(String userId, UpdateAdminPatientRequest request) async {
    await _apiClient.put('${ApiConstants.adminPatients}/$userId', body: request.toJson());
  }

  Future<void> deletePatient(String userId) async {
    await _apiClient.delete('${ApiConstants.adminPatients}/$userId');
  }

  Future<List<AdminPatientItem>> fetchPatients() async {
    final res = await _apiClient.get(ApiConstants.adminPatients);
    final data = res['data'];
    final raw = (data is Map<String, dynamic> ? data['items'] : null) ?? res['patients'] ?? res['items'] ?? data ?? res;
    if (raw is List) {
      return raw
          .map((e) => AdminPatientItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }
    return const <AdminPatientItem>[];
  }
}

import '../constants/api_constants.dart';
import 'api_client.dart';

class PatientAuthRepo {
  PatientAuthRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return _apiClient.post(
      ApiConstants.patientRegister,
      body: {'email': email, 'password': password, 'fullName': fullName},
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _apiClient.post(
      ApiConstants.patientLogin,
      body: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    return _apiClient.post(
      ApiConstants.patientRefresh,
      body: {'refreshToken': refreshToken},
    );
  }

  Future<void> sendForgotPasswordOtp({required String email}) async {
    await _apiClient.post(
      ApiConstants.patientForgotPasswordSendOtp,
      body: {'email': email},
    );
  }

  Future<void> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.patientForgotPasswordReset,
      body: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
  }
}

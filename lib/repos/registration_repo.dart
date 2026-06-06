import '../constants/api_constants.dart';
import 'api_client.dart';

class RegistrationRepo {
  RegistrationRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<void> sendVerifyEmailOtp({required String email}) async {
    await _apiClient.post(
      ApiConstants.registrationVerifyEmailSendOtp,
      body: {'email': email},
    );
  }

  Future<void> confirmVerifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    await _apiClient.post(
      ApiConstants.registrationVerifyEmailConfirm,
      body: {'email': email, 'otp': otp},
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _apiClient.post(
      ApiConstants.registrationLogin,
      body: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    return _apiClient.post(
      ApiConstants.registrationRefresh,
      body: {'refreshToken': refreshToken},
    );
  }

  Future<void> sendForgotPasswordOtp({required String email}) async {
    await _apiClient.post(
      ApiConstants.registrationForgotPasswordSendOtp,
      body: {'email': email},
    );
  }

  Future<void> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.registrationForgotPasswordReset,
      body: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.registrationChangePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> deleteAccount({Map<String, dynamic>? body}) async {
    await _apiClient.delete(ApiConstants.registrationDeleteAccount, body: body);
  }

  Future<void> logout() async {
    await _apiClient.post(ApiConstants.registrationLogout);
  }
}

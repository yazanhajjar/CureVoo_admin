class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';

  static const String health = '/health';
  static const String uploads = '/uploads';

  static const String register = '/api/auth/register';
  static const String registerDoctor = '/api/auth/register-doctor';
  static const String login = '/api/auth/login';
  static const String validateToken = '/api/auth/validate-token';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';

  static const String createAccount = '/api/registration/create-account';
  static const String registrationVerifyEmailSendOtp = '/api/registration/verify-email/send-otp';
  static const String registrationVerifyEmailConfirm = '/api/registration/verify-email/confirm';
  static const String registrationLogin = '/api/registration/login';
  static const String registrationRefresh = '/api/registration/refresh';
  static const String registrationForgotPasswordSendOtp = '/api/registration/forgot-password/send-otp';
  static const String registrationForgotPasswordReset = '/api/registration/forgot-password/reset';
  static const String registrationChangePassword = '/api/registration/change-password';
  static const String registrationDeleteAccount = '/api/registration/delete-account';
  static const String registrationLogout = '/api/registration/logout';

  static const String patientRegister = '/api/patients/register';
  static const String patientLogin = '/api/patients/login';
  static const String patientRefresh = '/api/patients/refresh';
  static const String patientForgotPasswordSendOtp = '/api/patients/forgot-password/send-otp';
  static const String patientForgotPasswordReset = '/api/patients/forgot-password/reset';

  static const String articles = '/api/admin/knowledge-articles';
  static const String patientArticles = '/api/patient/psychological-support/articles';
  static const String notifications = '/api/registration/notifications';

  static const String diagnosisStart = '/api/ai/cancer-diagnosis/start';
  static const String diagnosisMessage = '/api/ai/cancer-diagnosis/message';
  static const String diagnosisImage = '/api/ai/cancer-diagnosis/image';
  static const String resistanceStart = '/api/ai/cancer-resistance/start';
  static const String resistanceMessage = '/api/ai/cancer-resistance/message';

  static const String adminDoctors = '/api/admin/users/doctors';
  static const String adminPatients = '/api/admin/users/patients';
}

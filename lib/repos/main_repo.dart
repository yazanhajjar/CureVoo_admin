import 'api_client.dart';
import 'accounts_repo.dart';
import 'admin_users_repo.dart';
import 'ai_repo.dart';
import 'auth_repo.dart';
import 'knowledge_articles_repo.dart';
import 'patient_auth_repo.dart';
import 'notifications_repo.dart';
import 'public_repo.dart';
import 'registration_repo.dart';

class MainRepo {
  MainRepo._(this.apiClient)
      : authRepo = AuthRepo(apiClient),
        accountsRepo = AccountsRepo(apiClient),
        adminUsersRepo = AdminUsersRepo(apiClient),
        articlesRepo = KnowledgeArticlesRepo(apiClient),
        notificationsRepo = NotificationsRepo(apiClient),
        aiRepo = AiRepo(apiClient),
        registrationRepo = RegistrationRepo(apiClient),
        patientAuthRepo = PatientAuthRepo(apiClient),
        publicRepo = PublicRepo(apiClient);

  factory MainRepo.create() => MainRepo._(ApiClient());

  final ApiClient apiClient;
  final AuthRepo authRepo;
  final AccountsRepo accountsRepo;
  final AdminUsersRepo adminUsersRepo;
  final KnowledgeArticlesRepo articlesRepo;
  final NotificationsRepo notificationsRepo;
  final AiRepo aiRepo;
  final RegistrationRepo registrationRepo;
  final PatientAuthRepo patientAuthRepo;
  final PublicRepo publicRepo;
}

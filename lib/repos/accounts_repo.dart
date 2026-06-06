import '../constants/api_constants.dart';
import '../models/accounts/create_admin_account_request.dart';
import 'api_client.dart';

class AccountsRepo {
  AccountsRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createAccount(CreateAdminAccountRequest request) async {
    await _apiClient.post(ApiConstants.createAccount, body: request.toJson());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/accounts/create_admin_account_request.dart';
import '../../repos/accounts_repo.dart';
import '../../repos/api_client.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit(this._repo) : super(const AccountsState());

  final AccountsRepo _repo;

  Future<void> createAccount(CreateAdminAccountRequest request) async {
    emit(state.copyWith(status: AccountsStatus.submitting, clearMessage: true));
    try {
      await _repo.createAccount(request);
      emit(state.copyWith(status: AccountsStatus.success, message: 'Account created successfully.'));
      emit(state.copyWith(status: AccountsStatus.initial));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AccountsStatus.failure, message: e.message));
      emit(state.copyWith(status: AccountsStatus.initial));
    } catch (_) {
      emit(state.copyWith(status: AccountsStatus.failure, message: 'Failed to create account.'));
      emit(state.copyWith(status: AccountsStatus.initial));
    }
  }
}

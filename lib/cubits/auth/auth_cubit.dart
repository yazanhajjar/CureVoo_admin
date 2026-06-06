import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repos/api_client.dart';
import '../../repos/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(const AuthState()) {
    _authRepo.setSessionClearedCallback(_onSessionClearedFromRepo);
  }

  final AuthRepo _authRepo;
  static const _sessionExpiredMessage = 'Session expired. Please login again.';

  Future<void> initialize() async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final session = await _authRepo.restoreSession();
      if (session == null) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          isBusy: false,
          clearError: true,
        ));
        return;
      }

      await _authRepo.validateToken();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isBusy: false,
        clearError: true,
      ));
    } on ApiException {
      await _authRepo.clearSession();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        isBusy: false,
        errorMessage: _sessionExpiredMessage,
      ));
    } catch (_) {
      await _authRepo.clearSession();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        isBusy: false,
        errorMessage: _sessionExpiredMessage,
      ));
    }
  }

  Future<bool> login({required String email, required String password}) async {
    emit(state.copyWith(isBusy: true, clearError: true));

    try {
      final session = await _authRepo.login(email: email, password: password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isBusy: false,
        clearError: true,
      ));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        isBusy: false,
        errorMessage: e.message,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        isBusy: false,
        errorMessage: 'Login failed. Please try again.',
      ));
      return false;
    }
  }

  Future<bool> logout() async {
    emit(state.copyWith(isBusy: true, clearError: true));
    await _authRepo.logout();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearSession: true,
      isBusy: false,
      clearError: true,
    ));
    return true;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      await _authRepo.register(email: email, password: password, fullName: fullName);
      emit(state.copyWith(isBusy: false, clearError: true));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(isBusy: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(state.copyWith(isBusy: false, errorMessage: 'Registration failed. Please try again.'));
      return false;
    }
  }

  Future<bool> registerDoctor({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      await _authRepo.registerDoctor(email: email, password: password, fullName: fullName);
      emit(state.copyWith(isBusy: false, clearError: true));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(isBusy: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(state.copyWith(isBusy: false, errorMessage: 'Doctor registration failed. Please try again.'));
      return false;
    }
  }

  void _onSessionClearedFromRepo() {
    if (isClosed) return;
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearSession: true,
      isBusy: false,
      errorMessage: _sessionExpiredMessage,
    ));
  }
}

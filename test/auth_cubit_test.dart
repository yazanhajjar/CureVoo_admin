import 'package:curevoo_admin/cubits/auth/auth_cubit.dart';
import 'package:curevoo_admin/cubits/auth/auth_state.dart';
import 'package:curevoo_admin/models/auth/admin_session.dart';
import 'package:curevoo_admin/models/auth/auth_tokens.dart';
import 'package:curevoo_admin/repos/api_client.dart';
import 'package:curevoo_admin/repos/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepo extends AuthRepo {
  _FakeAuthRepo() : super(ApiClient());

  bool shouldFail = false;
  bool shouldFailValidate = false;
  bool logoutCalled = false;
  bool clearSessionCalled = false;
  AdminSession? restoreSessionValue;
  void Function()? _sessionClearedCallback;

  @override
  Future<AdminSession> login({required String email, required String password}) async {
    if (shouldFail) {
      throw ApiException('Invalid credentials', statusCode: 401);
    }
    return AdminSession(
      email: email,
      role: 'ADMIN',
      tokens: const AuthTokens(accessToken: 'token'),
    );
  }

  @override
  Future<AdminSession?> restoreSession() async => restoreSessionValue;

  @override
  Future<bool> validateToken() async {
    if (shouldFailValidate) {
      throw ApiException('Token invalid', statusCode: 401);
    }
    return true;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<void> clearSession() async {
    clearSessionCalled = true;
  }

  @override
  void setSessionClearedCallback(void Function() callback) {
    _sessionClearedCallback = callback;
  }

  void simulateSecuritySessionClear() {
    _sessionClearedCallback?.call();
  }
}

void main() {
  test('AuthCubit emits authenticated on successful login', () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);

    await cubit.login(email: 'admin@example.com', password: 'Pass1234!');

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.session?.email, 'admin@example.com');

    await cubit.close();
  });

  test('AuthCubit returns unauthenticated on failed login', () async {
    final repo = _FakeAuthRepo()..shouldFail = true;
    final cubit = AuthCubit(repo);

    await cubit.login(email: 'admin@example.com', password: 'bad');

    expect(cubit.state.status, AuthStatus.unauthenticated);

    await cubit.close();
  });

  test('AuthCubit handles security session clear with standardized message', () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);

    await cubit.login(email: 'admin@example.com', password: 'Pass1234!');
    expect(cubit.state.status, AuthStatus.authenticated);

    repo.simulateSecuritySessionClear();

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.errorMessage, 'Session expired. Please login again.');

    await cubit.close();
  });

  test('AuthCubit initialize emits unauthenticated when no stored session', () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);

    await cubit.initialize();

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.session, isNull);
    expect(cubit.state.errorMessage, isNull);

    await cubit.close();
  });

  test('AuthCubit initialize restores authenticated session when token validates', () async {
    final repo = _FakeAuthRepo()
      ..restoreSessionValue = AdminSession(
        email: 'admin@example.com',
        role: 'ADMIN',
        tokens: const AuthTokens(accessToken: 'token'),
      );
    final cubit = AuthCubit(repo);

    await cubit.initialize();

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.session?.email, 'admin@example.com');

    await cubit.close();
  });

  test('AuthCubit initialize clears session and shows expiry message when validate fails', () async {
    final repo = _FakeAuthRepo()
      ..restoreSessionValue = AdminSession(
        email: 'admin@example.com',
        role: 'ADMIN',
        tokens: const AuthTokens(accessToken: 'token'),
      )
      ..shouldFailValidate = true;
    final cubit = AuthCubit(repo);

    await cubit.initialize();

    expect(repo.clearSessionCalled, isTrue);
    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.errorMessage, 'Session expired. Please login again.');

    await cubit.close();
  });

  test('AuthCubit logout always returns unauthenticated and calls repo logout', () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);

    await cubit.login(email: 'admin@example.com', password: 'Pass1234!');
    expect(cubit.state.status, AuthStatus.authenticated);

    await cubit.logout();

    expect(repo.logoutCalled, isTrue);
    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.session, isNull);

    await cubit.close();
  });
}

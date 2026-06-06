import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../models/auth/admin_session.dart';
import '../models/auth/auth_tokens.dart';
import 'api_client.dart';

class AuthRepo {
  AuthRepo(this._apiClient) {
    _apiClient.setTokenRefreshCallback(_refreshAccessToken);
    _apiClient.setAuthFailureCallback(clearSession);
  }

  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _kAccessToken = 'accessToken';
  static const _kRefreshToken = 'refreshToken';
  static const _kUserEmail = 'userEmail';
  static const _kUserRole = 'userRole';
  void Function()? _sessionClearedCallback;

  void setSessionClearedCallback(void Function() callback) {
    _sessionClearedCallback = callback;
  }

  Future<AdminSession> login({
    required String email,
    required String password,
  }) async {
    final res = await _apiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    final data = (res['data'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : res;

    final tokens = AuthTokens.fromJson(data);
    if (tokens.accessToken.isEmpty) {
      throw ApiException('Missing access token in login response');
    }
    final role = _extractRoleFromJwt(tokens.accessToken);
    if (role != 'ADMIN') {
      await clearSession();
      throw ApiException('Access denied. This dashboard requires an ADMIN account.', statusCode: 403);
    }

    _apiClient.setAccessToken(tokens.accessToken);
    await _persistSession(email: email, role: role, tokens: tokens);

    return AdminSession(email: email, role: role, tokens: tokens);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _apiClient.post(
      ApiConstants.register,
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );
  }

  Future<void> registerDoctor({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _apiClient.post(
      ApiConstants.registerDoctor,
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );
  }

  Future<bool> validateToken() async {
    await _apiClient.get(ApiConstants.validateToken);
    return true;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {}

    await clearSession();
  }

  Future<AdminSession?> restoreSession() async {
    final accessToken = await _secureStorage.read(key: _kAccessToken);
    final refreshToken = await _secureStorage.read(key: _kRefreshToken);
    final email = await _secureStorage.read(key: _kUserEmail);
    final role = await _secureStorage.read(key: _kUserRole);

    if (accessToken == null || accessToken.isEmpty || email == null || email.isEmpty) {
      return null;
    }
    final resolvedRole = (role == null || role.isEmpty) ? _extractRoleFromJwt(accessToken) : role;
    if (resolvedRole != 'ADMIN') {
      await clearSession();
      return null;
    }

    _apiClient.setAccessToken(accessToken);
    return AdminSession(
      email: email,
      role: resolvedRole,
      tokens: AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
    );
  }

  Future<void> clearSession() async {
    _apiClient.setAccessToken(null);
    _apiClient.clearCookies();
    await _secureStorage.delete(key: _kAccessToken);
    await _secureStorage.delete(key: _kRefreshToken);
    await _secureStorage.delete(key: _kUserEmail);
    await _secureStorage.delete(key: _kUserRole);
    _sessionClearedCallback?.call();
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: _kRefreshToken);

    try {
      final primary = await _tryRefresh(
        endpoint: ApiConstants.refresh,
        refreshToken: refreshToken,
        includeRefreshTokenInBody: false,
      );
      if (primary != null && primary.isNotEmpty) {
        return primary;
      }

      // Optional fallback for older backends that only expose registration refresh.
      final fallback = await _tryRefresh(
        endpoint: ApiConstants.registrationRefresh,
        refreshToken: refreshToken,
        fallbackOnNotFoundOnly: true,
      );
      if (fallback != null && fallback.isNotEmpty) {
        return fallback;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _tryRefresh({
    required String endpoint,
    required String? refreshToken,
    bool fallbackOnNotFoundOnly = false,
    bool includeRefreshTokenInBody = true,
  }) async {
    try {
      final res = await _apiClient.post(
        endpoint,
        body: includeRefreshTokenInBody && (refreshToken != null && refreshToken.isNotEmpty)
            ? {'refreshToken': refreshToken}
            : null,
      );
      final data = (res['data'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(res['data'] as Map)
          : res;
      final tokens = AuthTokens.fromJson(data);
      if (tokens.accessToken.isEmpty) return null;

      final role = _extractRoleFromJwt(tokens.accessToken);
      if (role != 'ADMIN') {
        await clearSession();
        return null;
      }

      final email = await _secureStorage.read(key: _kUserEmail) ?? '';
      await _persistSession(email: email, role: role, tokens: tokens);
      _apiClient.setAccessToken(tokens.accessToken);
      return tokens.accessToken;
    } on ApiException catch (e) {
      if (fallbackOnNotFoundOnly && e.statusCode != 404 && e.statusCode != 405) {
        rethrow;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSession({
    required String email,
    required String role,
    required AuthTokens tokens,
  }) async {
    await _secureStorage.write(key: _kAccessToken, value: tokens.accessToken);
    if (tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty) {
      await _secureStorage.write(key: _kRefreshToken, value: tokens.refreshToken!);
    }
    await _secureStorage.write(key: _kUserEmail, value: email);
    await _secureStorage.write(key: _kUserRole, value: role);
  }

  String _extractRoleFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return '';
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return (map['role'] ?? map['userRole'] ?? '').toString().toUpperCase();
    } catch (_) {
      return '';
    }
  }
}

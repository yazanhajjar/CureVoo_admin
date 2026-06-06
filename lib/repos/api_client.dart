import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'http_client_factory.dart';

typedef TokenRefreshCallback = Future<String?> Function();
typedef AuthFailureCallback = Future<void> Function();

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code, this.details});

  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, code: $code, message: $message, details: $details)';
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? createHttpClient();

  final http.Client _http;
  String? _accessToken;
  final Map<String, String> _cookies = <String, String>{};
  TokenRefreshCallback? _tokenRefreshCallback;
  AuthFailureCallback? _authFailureCallback;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void clearCookies() {
    _cookies.clear();
  }

  void setTokenRefreshCallback(TokenRefreshCallback callback) {
    _tokenRefreshCallback = callback;
  }

  void setAuthFailureCallback(AuthFailureCallback callback) {
    _authFailureCallback = callback;
  }

  Future<Map<String, dynamic>> get(String path) async {
    return _send('GET', path);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    return _send('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path, {Map<String, dynamic>? body}) async {
    return _send('DELETE', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool allowRetry = true,
  }) async {
    final response = await _sendRaw(method, path, body: body);
    _captureCookies(response);
    final payload = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizePayload(payload);
    }

    if (response.statusCode == 401 &&
        allowRetry &&
        path != ApiConstants.login &&
        path != ApiConstants.refresh &&
        path != ApiConstants.registrationRefresh &&
        path != ApiConstants.patientRefresh) {
      final refreshedToken = await _tokenRefreshCallback?.call();
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        _accessToken = refreshedToken;
        return _send(method, path, body: body, allowRetry: false);
      }
      await _authFailureCallback?.call();
    }

    if (response.statusCode == 403) {
      final errorCode = _extractErrorCode(payload);
      if (errorCode == 'CSRF_INVALID' || errorCode == 'CORS_FORBIDDEN') {
        await _authFailureCallback?.call();
      }
    }

    throw _buildException(response.statusCode, payload);
  }

  Future<http.Response> _sendRaw(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }
    _attachCsrfHeaderIfAvailable(headers);

    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _http.get(uri, headers: headers);
      case 'POST':
        return _http.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _http.put(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _http.delete(uri, headers: headers, body: encodedBody);
      default:
        throw ApiException('Unsupported method: $method');
    }
  }

  void _attachCsrfHeaderIfAvailable(Map<String, String> headers) {
    final csrfToken = _cookies['csrf_token'];
    if (csrfToken == null || csrfToken.isEmpty) return;
    headers['x-csrf-token'] = csrfToken;
  }

  void _captureCookies(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) return;

    final chunks = setCookie.split(RegExp(r',(?=[^;]+?=)'));
    for (final chunk in chunks) {
      final firstPart = chunk.split(';').first.trim();
      final separatorIndex = firstPart.indexOf('=');
      if (separatorIndex <= 0) continue;
      final name = firstPart.substring(0, separatorIndex).trim();
      final value = firstPart.substring(separatorIndex + 1).trim();
      if (name.isEmpty) continue;
      if (value.isEmpty) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{'raw': body};
    }
  }

  Map<String, dynamic> _normalizePayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return {'data': payload};
  }

  ApiException _buildException(int statusCode, dynamic payload) {
    var message = 'Request failed';
    String? code;
    dynamic details;
    if (payload is Map<String, dynamic>) {
      message = (payload['message'] ?? payload['error'] ?? message).toString();
      code = _extractErrorCode(payload);
      details = payload['details'] ?? (payload['error'] is Map<String, dynamic> ? payload['error']['details'] : null);
    }
    return ApiException(message, statusCode: statusCode, code: code, details: details);
  }

  String? _extractErrorCode(dynamic payload) {
    if (payload is! Map<String, dynamic>) return null;
    final raw = payload['code'] ?? payload['errorCode'];
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty) return null;
    return value;
  }
}

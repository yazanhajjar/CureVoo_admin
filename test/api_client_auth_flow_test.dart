import 'dart:async';
import 'dart:convert';

import 'package:curevoo_admin/constants/api_constants.dart';
import 'package:curevoo_admin/repos/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

typedef _ResponseBuilder = http.Response Function(http.BaseRequest request);

class _QueueHttpClient extends http.BaseClient {
  _QueueHttpClient(this._builders);

  final List<_ResponseBuilder> _builders;
  final List<http.BaseRequest> requests = <http.BaseRequest>[];
  int _index = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (_index >= _builders.length) {
      throw StateError('No queued response for request #$_index');
    }
    final response = _builders[_index](request);
    _index += 1;
    final bytes = utf8.encode(response.body);
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      response.statusCode,
      headers: response.headers,
      request: request,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

void main() {
  test('ApiClient retries once after 401 when token refresh succeeds', () async {
    var refreshCalled = 0;
    final queued = _QueueHttpClient(<_ResponseBuilder>[
      (_) => http.Response('{"message":"expired"}', 401),
      (_) => http.Response('{"data":{"ok":true}}', 200),
    ]);
    final client = ApiClient(httpClient: queued)..setAccessToken('old-token');
    client.setTokenRefreshCallback(() async {
      refreshCalled += 1;
      return 'new-token';
    });

    final result = await client.get(ApiConstants.adminDoctors);

    expect(refreshCalled, 1);
    expect(result['data']['ok'], true);
    expect(queued.requests, hasLength(2));
    expect(queued.requests.first.headers['authorization'], 'Bearer old-token');
    expect(queued.requests.last.headers['authorization'], 'Bearer new-token');
  });

  test('ApiClient triggers auth failure callback for 403 CSRF_INVALID', () async {
    var authFailureCalled = 0;
    final queued = _QueueHttpClient(<_ResponseBuilder>[
      (_) => http.Response('{"code":"CSRF_INVALID","message":"bad csrf"}', 403),
    ]);
    final client = ApiClient(httpClient: queued);
    client.setAuthFailureCallback(() async {
      authFailureCalled += 1;
    });

    await expectLater(
      () => client.post(ApiConstants.refresh),
      throwsA(isA<ApiException>()),
    );
    expect(authFailureCalled, 1);
  });

  test('ApiClient attaches csrf header from captured cookie on refresh/logout', () async {
    final queued = _QueueHttpClient(<_ResponseBuilder>[
      (_) => http.Response(
            '{"data":{"ok":true}}',
            200,
            headers: <String, String>{'set-cookie': 'csrf_token=csrf-123; Path=/; HttpOnly'},
          ),
      (request) {
        expect(request.headers['x-csrf-token'], 'csrf-123');
        return http.Response('{"data":{"ok":true}}', 200);
      },
      (request) {
        expect(request.headers['x-csrf-token'], 'csrf-123');
        return http.Response('{"data":{"ok":true}}', 200);
      },
    ]);
    final client = ApiClient(httpClient: queued);

    await client.post(ApiConstants.login, body: <String, dynamic>{'email': 'a', 'password': 'b'});
    await client.post(ApiConstants.refresh);
    await client.post(ApiConstants.logout);
  });
}

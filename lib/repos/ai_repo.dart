import '../constants/api_constants.dart';
import 'api_client.dart';

class AiRepo {
  AiRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<String> startDiagnosis({required String sessionId}) async {
    final res = await _apiClient.post(
      ApiConstants.diagnosisStart,
      body: {
        'sessionId': sessionId,
        'entryIntent': '/start_questions_and_image',
      },
    );
    return _extractText(res);
  }

  Future<String> sendDiagnosisMessage({required String sessionId, required String message}) async {
    final res = await _apiClient.post(
      ApiConstants.diagnosisMessage,
      body: {'sessionId': sessionId, 'message': message},
    );
    return _extractText(res);
  }

  Future<String> sendDiagnosisImage({
    required String sessionId,
    required String imageReference,
  }) async {
    final res = await _apiClient.post(
      ApiConstants.diagnosisImage,
      body: {
        'sessionId': sessionId,
        'image': imageReference,
      },
    );
    return _extractText(res);
  }

  Future<String> startResistance({required String sessionId}) async {
    final res = await _apiClient.post(
      ApiConstants.resistanceStart,
      body: {
        'sessionId': sessionId,
        'entryIntent': '/start_cancer_resistance',
      },
    );
    return _extractText(res);
  }

  Future<String> sendResistanceMessage({required String sessionId, required String message}) async {
    final res = await _apiClient.post(
      ApiConstants.resistanceMessage,
      body: {'sessionId': sessionId, 'message': message},
    );
    return _extractText(res);
  }

  String _extractText(Map<String, dynamic> data) {
    final payload = data['data'] ?? data;
    if (payload is String) return payload;
    if (payload is Map<String, dynamic>) {
      final candidates = [
        payload['message'],
        payload['text'],
        payload['response'],
        payload['reply'],
      ];
      for (final candidate in candidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate;
        }
      }

      if (payload['messages'] is List) {
        final nested = _extractFromList(payload['messages'] as List);
        if (nested != null) return nested;
      }
      return payload.toString();
    }
    if (payload is List) {
      final extracted = _extractFromList(payload);
      if (extracted != null) return extracted;
    }
    return 'Done';
  }

  String? _extractFromList(List items) {
    if (items.isEmpty) return null;

    final buffer = <String>[];
    for (final item in items) {
      if (item is String && item.trim().isNotEmpty) {
        buffer.add(item.trim());
      } else if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final text = map['text'] ?? map['message'] ?? map['response'];
        if (text is String && text.trim().isNotEmpty) {
          buffer.add(text.trim());
        }
      }
    }

    if (buffer.isEmpty) return null;
    return buffer.join('\n');
  }
}

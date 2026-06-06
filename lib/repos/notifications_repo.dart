import '../constants/api_constants.dart';
import '../models/notifications/admin_notification.dart';
import 'api_client.dart';

class NotificationsRepo {
  NotificationsRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminNotification>> fetchNotifications() async {
    final res = await _apiClient.get(ApiConstants.notifications);
    final raw = res['data'] ?? res['notifications'] ?? res['items'] ?? res;

    if (raw is List) {
      return raw
          .map((e) => AdminNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return <AdminNotification>[];
  }
}

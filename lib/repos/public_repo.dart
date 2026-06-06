import '../constants/api_constants.dart';
import 'api_client.dart';

class PublicRepo {
  PublicRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> health() async {
    return _apiClient.get(ApiConstants.health);
  }

  String uploadUrl(String relativePath) {
    final trimmed = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return '${ApiConstants.baseUrl}${ApiConstants.uploads}/$trimmed';
  }
}

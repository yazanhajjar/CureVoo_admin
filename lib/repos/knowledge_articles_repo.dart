import '../constants/api_constants.dart';
import '../models/articles/article_requests.dart';
import '../models/articles/knowledge_article.dart';
import 'api_client.dart';

class KnowledgeArticlesRepo {
  KnowledgeArticlesRepo(this._apiClient);

  final ApiClient _apiClient;

  Future<List<KnowledgeArticle>> fetchArticles({
    String? category,
    String? language,
  }) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (language != null && language.isNotEmpty) query['language'] = language;
    final path = query.isEmpty
        ? ApiConstants.articles
        : '${ApiConstants.articles}?${Uri(queryParameters: query).query}';

    try {
      final res = await _apiClient.get(path);
      final data = res['data'];
      final raw = (data is Map<String, dynamic> ? data['items'] : null) ??
          res['articles'] ??
          res['items'] ??
          data ??
          res;
      if (raw is List) {
        return raw
            .map((e) => KnowledgeArticle.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return <KnowledgeArticle>[];
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) {
        return _fetchFromPatientReadEndpoint();
      }
      rethrow;
    }
  }

  Future<List<KnowledgeArticle>> _fetchFromPatientReadEndpoint() async {
    final res = await _apiClient.get(ApiConstants.patientArticles);
    final data = res['data'];
    final raw = (data is Map<String, dynamic> ? data['items'] : null) ??
        res['articles'] ??
        res['items'] ??
        data ??
        res;
    if (raw is List) {
      return raw
          .map((e) => KnowledgeArticle.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <KnowledgeArticle>[];
  }

  Future<KnowledgeArticle> createArticle(CreateArticleRequest request) async {
    final res = await _apiClient.post(ApiConstants.articles, body: request.toJson());
    final data = (res['data'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : res;
    return KnowledgeArticle.fromJson(data);
  }

  Future<KnowledgeArticle> updateArticle(String id, UpdateArticleRequest request) async {
    final res = await _apiClient.put('${ApiConstants.articles}/$id', body: request.toJson());
    final data = (res['data'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : res;
    return KnowledgeArticle.fromJson(data);
  }

  Future<void> deleteArticle(String id) async {
    await _apiClient.delete('${ApiConstants.articles}/$id');
  }

  Future<KnowledgeArticle> fetchArticleById(String id) async {
    final res = await _apiClient.get('${ApiConstants.articles}/$id');
    final data = (res['data'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : res;
    return KnowledgeArticle.fromJson(data);
  }

  Future<Map<String, dynamic>> fetchArticleMetadataById(String id) async {
    final res = await _apiClient.get('${ApiConstants.articles}/$id/metadata');
    final data = (res['data'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : res;
    return data;
  }
}

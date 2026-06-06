import 'package:curevoo_admin/cubits/articles/articles_cubit.dart';
import 'package:curevoo_admin/cubits/articles/articles_state.dart';
import 'package:curevoo_admin/models/articles/article_requests.dart';
import 'package:curevoo_admin/models/articles/knowledge_article.dart';
import 'package:curevoo_admin/repos/api_client.dart';
import 'package:curevoo_admin/repos/knowledge_articles_repo.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeArticlesRepo extends KnowledgeArticlesRepo {
  _FakeArticlesRepo() : super(ApiClient());

  final List<KnowledgeArticle> _items = [];
  bool shouldFail = false;

  @override
  Future<List<KnowledgeArticle>> fetchArticles({String? category, String? language}) async {
    if (shouldFail) throw ApiException('Failed');
    return List<KnowledgeArticle>.from(_items);
  }

  @override
  Future<KnowledgeArticle> createArticle(CreateArticleRequest request) async {
    if (shouldFail) throw ApiException('Failed');
    final article = KnowledgeArticle(
      id: '1',
      title: request.title,
      category: request.category,
      summary: request.summary,
      content: request.content,
      sources: request.sources ?? const [],
      language: request.language ?? 'en',
      isPublished: request.isPublished,
    );
    _items.add(article);
    return article;
  }
}

void main() {
  test('ArticlesCubit loads articles', () async {
    final repo = _FakeArticlesRepo();
    final cubit = ArticlesCubit(repo);

    await cubit.loadArticles();

    expect(cubit.state.status, ArticlesStatus.loaded);
    expect(cubit.state.articles, isEmpty);
    await cubit.close();
  });

  test('ArticlesCubit handles create', () async {
    final repo = _FakeArticlesRepo();
    final cubit = ArticlesCubit(repo);

    await cubit.createArticle(
      const CreateArticleRequest(
        title: 'Title',
        category: 'cancer',
        summary: 'sum',
        content: 'content',
        sources: [],
        language: 'en',
        isPublished: true,
      ),
    );

    expect(cubit.state.status, ArticlesStatus.loaded);
    expect(cubit.state.articles.length, 1);
    await cubit.close();
  });
}

import 'package:curevoo_admin/models/articles/article_source.dart';
import 'package:curevoo_admin/models/articles/knowledge_article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('KnowledgeArticle json roundtrip works', () {
    final article = KnowledgeArticle(
      id: '1',
      title: 'What is NSCLC?',
      category: 'cancer',
      summary: 'Simple explanation',
      content: 'NSCLC is ...',
      sources: const [ArticleSource(title: 'NCI', url: 'https://cancer.gov')],
      language: 'en',
      isPublished: true,
    );

    final map = article.toJson();
    final parsed = KnowledgeArticle.fromJson(map);

    expect(parsed.title, article.title);
    expect(parsed.sources.length, 1);
    expect(parsed.isPublished, true);
  });
}

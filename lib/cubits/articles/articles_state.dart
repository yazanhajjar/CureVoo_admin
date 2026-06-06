import 'package:equatable/equatable.dart';

import '../../models/articles/knowledge_article.dart';

enum ArticlesStatus { initial, loading, loaded, submitting, failure }

class ArticlesState extends Equatable {
  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const <KnowledgeArticle>[],
    this.errorMessage,
  });

  final ArticlesStatus status;
  final List<KnowledgeArticle> articles;
  final String? errorMessage;

  ArticlesState copyWith({
    ArticlesStatus? status,
    List<KnowledgeArticle>? articles,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, articles, errorMessage];
}

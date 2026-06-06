import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/articles/article_requests.dart';
import '../../models/articles/knowledge_article.dart';
import '../../repos/api_client.dart';
import '../../repos/knowledge_articles_repo.dart';
import 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  ArticlesCubit(this._articlesRepo) : super(const ArticlesState());

  final KnowledgeArticlesRepo _articlesRepo;

  Future<void> loadArticles({String? category, String? language}) async {
    emit(state.copyWith(status: ArticlesStatus.loading, clearError: true));
    try {
      final items = await _articlesRepo.fetchArticles(category: category, language: language);
      emit(state.copyWith(status: ArticlesStatus.loaded, articles: items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        errorMessage: 'Failed to load articles.',
      ));
    }
  }

  Future<void> createArticle(CreateArticleRequest request) async {
    emit(state.copyWith(status: ArticlesStatus.submitting, clearError: true));
    try {
      final created = await _articlesRepo.createArticle(request);
      final updated = List<KnowledgeArticle>.from(state.articles)..insert(0, created);
      emit(state.copyWith(status: ArticlesStatus.loaded, articles: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        errorMessage: 'Failed to create article.',
      ));
    }
  }

  Future<void> updateArticle(String id, UpdateArticleRequest request) async {
    final previousArticles = List<KnowledgeArticle>.from(state.articles);
    if (request.isPublished != null) {
      final optimistic = previousArticles
          .map(
            (item) => item.id == id
                ? KnowledgeArticle(
                    id: item.id,
                    title: item.title,
                    category: item.category,
                    summary: item.summary,
                    content: item.content,
                    sources: item.sources,
                    language: item.language,
                    isPublished: request.isPublished!,
                  )
                : item,
          )
          .toList(growable: false);
      emit(state.copyWith(status: ArticlesStatus.loaded, articles: optimistic, clearError: true));
    } else {
      emit(state.copyWith(status: ArticlesStatus.submitting, clearError: true));
    }
    try {
      final updatedFromApi = await _articlesRepo.updateArticle(id, request);
      final list = state.articles
          .map((item) => item.id == id ? _mergeUpdatedArticle(item, updatedFromApi, request) : item)
          .toList(growable: false);
      emit(state.copyWith(status: ArticlesStatus.loaded, articles: list));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: e.message, articles: previousArticles));
    } catch (_) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        errorMessage: 'Failed to update article.',
        articles: previousArticles,
      ));
    }
  }

  KnowledgeArticle _mergeUpdatedArticle(
    KnowledgeArticle current,
    KnowledgeArticle updatedFromApi,
    UpdateArticleRequest request,
  ) {
    final hasFullPayload = updatedFromApi.id.isNotEmpty && updatedFromApi.title.isNotEmpty;
    if (hasFullPayload) return updatedFromApi;

    return KnowledgeArticle(
      id: current.id,
      title: request.title ?? current.title,
      category: request.category ?? current.category,
      summary: request.summary ?? current.summary,
      content: request.content ?? current.content,
      sources: request.sources ?? current.sources,
      language: request.language ?? current.language,
      isPublished: request.isPublished ?? current.isPublished,
    );
  }

  Future<void> deleteArticle(String id) async {
    emit(state.copyWith(status: ArticlesStatus.submitting, clearError: true));
    try {
      await _articlesRepo.deleteArticle(id);
      final list = state.articles.where((item) => item.id != id).toList(growable: false);
      emit(state.copyWith(status: ArticlesStatus.loaded, articles: list));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        errorMessage: 'Failed to delete article.',
      ));
    }
  }

  Future<KnowledgeArticle?> loadArticleById(String id) async {
    emit(state.copyWith(status: ArticlesStatus.submitting, clearError: true));
    try {
      final article = await _articlesRepo.fetchArticleById(id);
      final list = List<KnowledgeArticle>.from(state.articles);
      final index = list.indexWhere((item) => item.id == id);
      if (index >= 0) {
        list[index] = article;
      } else {
        list.insert(0, article);
      }
      emit(state.copyWith(status: ArticlesStatus.loaded, articles: list));
      return article;
    } on ApiException catch (e) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: e.message));
      return null;
    } catch (_) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: 'Failed to load article details.'));
      return null;
    }
  }

  Future<Map<String, dynamic>?> loadArticleMetadataById(String id) async {
    emit(state.copyWith(status: ArticlesStatus.submitting, clearError: true));
    try {
      final metadata = await _articlesRepo.fetchArticleMetadataById(id);
      emit(state.copyWith(status: ArticlesStatus.loaded));
      return metadata;
    } on ApiException catch (e) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: e.message));
      return null;
    } catch (_) {
      emit(state.copyWith(status: ArticlesStatus.failure, errorMessage: 'Failed to load article metadata.'));
      return null;
    }
  }
}

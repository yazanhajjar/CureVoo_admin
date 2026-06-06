import 'package:equatable/equatable.dart';

import 'article_source.dart';

class KnowledgeArticle extends Equatable {
  const KnowledgeArticle({
    required this.id,
    required this.title,
    this.slug,
    required this.category,
    required this.summary,
    required this.content,
    required this.sources,
    required this.language,
    this.readingTimeMinutes,
    required this.isPublished,
  });

  final String id;
  final String title;
  final String? slug;
  final String category;
  final String summary;
  final String content;
  final List<ArticleSource> sources;
  final String language;
  final int? readingTimeMinutes;
  final bool? isPublished;

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) {
    final sourcesRaw = (json['sources'] as List?) ?? <dynamic>[];
    final metadata = json['metadata'] is Map<String, dynamic>
        ? json['metadata'] as Map<String, dynamic>
        : (json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata'] as Map) : const <String, dynamic>{});

    final publishValue = json.containsKey('isPublished')
        ? json['isPublished']
        : json.containsKey('is_published')
            ? json['is_published']
            : json.containsKey('published')
                ? json['published']
                : metadata.containsKey('isPublished')
                    ? metadata['isPublished']
                    : metadata.containsKey('is_published')
                        ? metadata['is_published']
                        : metadata['published'];

    return KnowledgeArticle(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '') as String,
      slug: json['slug']?.toString(),
      category: (json['category'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      sources: sourcesRaw
          .map((e) => ArticleSource.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      language: (json['language'] ?? 'en') as String,
      readingTimeMinutes: json['reading_time_minutes'] is int
          ? json['reading_time_minutes'] as int
          : int.tryParse('${json['reading_time_minutes'] ?? ''}'),
      isPublished: _parseNullableBool(publishValue),
    );
  }

  static bool? _parseNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (slug != null && slug!.isNotEmpty) 'slug': slug,
      'category': category,
      'summary': summary,
      'content': content,
      'sources': sources.map((e) => e.toJson()).toList(),
      'language': language,
      if (readingTimeMinutes != null) 'reading_time_minutes': readingTimeMinutes,
      if (isPublished != null) 'is_published': isPublished,
    };
  }

  @override
  List<Object?> get props => [id, title, slug, category, summary, content, sources, language, readingTimeMinutes, isPublished];
}

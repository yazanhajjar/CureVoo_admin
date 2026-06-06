import 'article_source.dart';

class CreateArticleRequest {
  const CreateArticleRequest({
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    this.slug,
    this.sources,
    this.language,
    this.readingTimeMinutes,
    required this.isPublished,
  });

  final String title;
  final String category;
  final String summary;
  final String content;
  final String? slug;
  final List<ArticleSource>? sources;
  final String? language;
  final int? readingTimeMinutes;
  final bool isPublished;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'category': category,
      'summary': summary,
      'content': content,
      'is_published': isPublished,
      'isPublished': isPublished,
    };
    if (slug != null && slug!.isNotEmpty) map['slug'] = slug;
    if (sources != null && sources!.isNotEmpty) {
      map['sources'] = sources!.map((e) => e.toJson()).toList();
    }
    if (language != null && language!.isNotEmpty) map['language'] = language;
    if (readingTimeMinutes != null) map['reading_time_minutes'] = readingTimeMinutes;
    return map;
  }
}

class UpdateArticleRequest {
  const UpdateArticleRequest({
    this.title,
    this.category,
    this.summary,
    this.content,
    this.slug,
    this.sources,
    this.language,
    this.readingTimeMinutes,
    this.isPublished,
  });

  final String? title;
  final String? category;
  final String? summary;
  final String? content;
  final String? slug;
  final List<ArticleSource>? sources;
  final String? language;
  final int? readingTimeMinutes;
  final bool? isPublished;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (category != null) map['category'] = category;
    if (summary != null) map['summary'] = summary;
    if (content != null) map['content'] = content;
    if (slug != null) map['slug'] = slug;
    if (sources != null) map['sources'] = sources!.map((e) => e.toJson()).toList();
    if (language != null) map['language'] = language;
    if (readingTimeMinutes != null) map['reading_time_minutes'] = readingTimeMinutes;
    if (isPublished != null) map['is_published'] = isPublished;
    if (isPublished != null) map['isPublished'] = isPublished;
    return map;
  }
}

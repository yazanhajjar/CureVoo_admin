import 'package:equatable/equatable.dart';

class ArticleSource extends Equatable {
  const ArticleSource({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      title: (json['title'] ?? '') as String,
      url: (json['url'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
    };
  }

  @override
  List<Object?> get props => [title, url];
}

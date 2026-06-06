import 'package:equatable/equatable.dart';

class AdminNotification extends Equatable {
  const AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    return AdminNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? json['subject'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['content'] ?? '').toString(),
      isRead: (json['isRead'] ?? json['is_read'] ?? false) as bool,
      createdAt: createdAtRaw is String ? DateTime.tryParse(createdAtRaw) : null,
    );
  }

  @override
  List<Object?> get props => [id, title, message, isRead, createdAt];
}

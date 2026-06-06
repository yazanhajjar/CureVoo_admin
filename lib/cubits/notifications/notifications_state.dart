import 'package:equatable/equatable.dart';

import '../../models/notifications/admin_notification.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const <AdminNotification>[],
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AdminNotification> items;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AdminNotification>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}

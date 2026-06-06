import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repos/api_client.dart';
import '../../repos/notifications_repo.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repo) : super(const NotificationsState());

  final NotificationsRepo _repo;

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading, clearError: true));
    try {
      final items = await _repo.fetchNotifications();
      emit(state.copyWith(status: NotificationsStatus.loaded, items: items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: NotificationsStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: NotificationsStatus.failure, errorMessage: 'Failed to load notifications.'));
    }
  }
}

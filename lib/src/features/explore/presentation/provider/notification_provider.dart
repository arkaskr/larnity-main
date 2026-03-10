import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/data/datasource/notification_datasource.dart';
import 'package:larnity/src/features/explore/data/models/notification_model.dart';

final notificationProvider =
    NotifierProvider.autoDispose<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);

class NotificationNotifier extends AutoDisposeNotifier<NotificationState> {
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;

  @override
  NotificationState build() {
    // Listen to auth state changes
    ref.listen(authProvider, (_, next) {
      final userId = next.user?.id;
      if (userId != null && userId.isNotEmpty) {
        _subscribeToNotifications(userId);
      } else {
        _notificationSubscription?.cancel();
        state = NotificationState(fetchState: AsyncState.initial);
      }
    });

    // Initial subscription
    Future.microtask(() async {
      final userId = ref.watch(authProvider).user?.id;
      if (userId != null && userId.isNotEmpty) {
        await fetchNotifications();
        _subscribeToNotifications(userId);
      }
    });

    ref.onDispose(() {
      _notificationSubscription?.cancel();
    });

    return NotificationState(fetchState: AsyncState.initial);
  }

  // Subscribe to real-time notifications
  void _subscribeToNotifications(String userId) {
    _notificationSubscription?.cancel();

    final dataSource = ref.read(notificationDataSourceProvider);
    _notificationSubscription =
        dataSource.subscribeToUserNotifications(userId).listen(
      (notifications) {
        state = state.copyWith(
          fetchState: AsyncState.success,
          notifications: notifications,
          unreadCount: notifications.where((n) => !n.isRead).length,
        );
        Log.info("📬 Received ${notifications.length} notifications");
      },
      onError: (error) {
        Log.error("❌ Notification stream error: $error");
        state = state.copyWith(
          fetchState: AsyncState.failure,
          error: error.toString(),
        );
      },
    );
  }


  // Fetch notifications (initial load)
  Future<void> fetchNotifications() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) {
      Log.error("❌ User not authenticated");
      return;
    }

    Log.info("🔍 Fetching notifications for user: $userId");
    state = state.copyWith(fetchState: AsyncState.loading);
    final dataSource = ref.read(notificationDataSourceProvider);
    final response = await dataSource.getNotificationsByUser(
      recipientId: userId,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          fetchState: AsyncState.failure,
          error: failure.message,
        );
        Log.error("❌ Fetch notifications failed: ${failure.message}");
      },
      (notifications) {
        state = state.copyWith(
          fetchState: AsyncState.success,
          notifications: notifications,
          unreadCount: notifications.where((n) => !n.isRead).length,
        );
        Log.info("✅ Fetched ${notifications.length} notifications");
      },
    );
  }

  // Get unread count
  Future<void> fetchUnreadCount() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) return;

    final dataSource = ref.read(notificationDataSourceProvider);
    final response = await dataSource.getUnreadCount(recipientId: userId);

    response.fold(
      (failure) => Log.error("❌ Get unread count failed: ${failure.message}"),
      (count) {
        state = state.copyWith(unreadCount: count);
        Log.info("✅ Unread count: $count");
      },
    );
  }

  // Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    state = state.copyWith(updateState: AsyncState.loading);
    final dataSource = ref.read(notificationDataSourceProvider);
    final response = await dataSource.markAsRead(notificationId: notificationId);

    response.fold(
      (failure) {
        state = state.copyWith(
          updateState: AsyncState.failure,
          error: failure.message,
        );
        Log.error("❌ Mark as read failed: ${failure.message}");
      },
      (updatedNotification) {
        // Update the notification in the list
        final updatedList = state.notifications?.map((n) {
          return n.id == notificationId ? updatedNotification : n;
        }).toList();

        state = state.copyWith(
          updateState: AsyncState.success,
          notifications: updatedList,
          unreadCount: updatedList?.where((n) => !n.isRead).length ?? 0,
        );
        Log.info("✅ Marked notification as read");
      },
    );
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) return;

    state = state.copyWith(updateState: AsyncState.loading);
    final dataSource = ref.read(notificationDataSourceProvider);
    final response = await dataSource.markAllAsRead(recipientId: userId);

    response.fold(
      (failure) {
        state = state.copyWith(
          updateState: AsyncState.failure,
          error: failure.message,
        );
        Log.error("❌ Mark all as read failed: ${failure.message}");
      },
      (_) {
        // Update all notifications to read
        final updatedList = state.notifications
            ?.map((n) => n.copyWith(isRead: true))
            .toList();

        state = state.copyWith(
          updateState: AsyncState.success,
          notifications: updatedList,
          unreadCount: 0,
        );
        Log.info("✅ Marked all notifications as read");
      },
    );
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    state = state.copyWith(deleteState: AsyncState.loading);
    final dataSource = ref.read(notificationDataSourceProvider);
    final response =
        await dataSource.deleteNotification(notificationId: notificationId);

    response.fold(
      (failure) {
        state = state.copyWith(
          deleteState: AsyncState.failure,
          error: failure.message,
        );
        Log.error("❌ Delete notification failed: ${failure.message}");
      },
      (_) {
        // Remove notification from list
        final updatedList = state.notifications
            ?.where((n) => n.id != notificationId)
            .toList();

        state = state.copyWith(
          deleteState: AsyncState.success,
          notifications: updatedList,
          unreadCount: updatedList?.where((n) => !n.isRead).length ?? 0,
        );
        Log.info("✅ Deleted notification");
      },
    );
  }

  // Filter notifications by group
  void filterByGroup(String? groupId) {
    state = state.copyWith(selectedGroupId: groupId);
  }

  // Get filtered notifications
  List<NotificationModel> get filteredNotifications {
    if (state.selectedGroupId == null) {
      return state.notifications ?? [];
    }
    return state.notifications
            ?.where((n) => n.groupId == state.selectedGroupId)
            .toList() ??
        [];
  }
}

class NotificationState {
  final AsyncState? fetchState;
  final AsyncState? updateState;
  final AsyncState? deleteState;
  final String? error;
  final List<NotificationModel>? notifications;
  final int unreadCount;
  final String? selectedGroupId;

  NotificationState({
    this.fetchState,
    this.updateState,
    this.deleteState,
    this.error,
    this.notifications,
    this.unreadCount = 0,
    this.selectedGroupId,
  });

  NotificationState copyWith({
    AsyncState? fetchState,
    AsyncState? updateState,
    AsyncState? deleteState,
    String? error,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? selectedGroupId,
    bool clearGroupFilter = false,
  }) {
    return NotificationState(
      fetchState: fetchState ?? this.fetchState,
      updateState: updateState ?? this.updateState,
      deleteState: deleteState ?? this.deleteState,
      error: error ?? this.error,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedGroupId: clearGroupFilter ? null : (selectedGroupId ?? this.selectedGroupId),
    );
  }

  bool get isLoading => fetchState == AsyncState.loading;
  bool get isSuccess => fetchState == AsyncState.success;
  bool get isFailure => fetchState == AsyncState.failure;
  bool get hasNotifications => notifications != null && notifications!.isNotEmpty;
}

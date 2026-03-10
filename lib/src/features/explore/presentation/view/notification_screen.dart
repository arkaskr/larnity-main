import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/explore/presentation/provider/notification_provider.dart';
import 'package:larnity/src/features/explore/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  String _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.group_invite:
      case NotificationType.group_update:
        return "🎉";
      case NotificationType.payment_success:
        return "💰";
      case NotificationType.payment_failed:
        return "❌";
      case NotificationType.subscription_expiry:
        return "⏰";
      case NotificationType.promotion_alert:
        return "🎁";
      case NotificationType.user_mention:
        return "👤";
      case NotificationType.comment_reply:
        return "💬";
      case NotificationType.like:
        return "❤️";
      case NotificationType.follow:
        return "👥";
      default:
        return "🔔";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final notifications = notifier.filteredNotifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.notification01,
                      color: AppColors.blue,
                    ),
                    AppSizes.xxs.pw,
                    Text(
                      "Notifications",
                      style: AppTextStyles.headline4().copyWith(
                        fontWeight: AppFontWeights.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        notifier.markAllAsRead();
                      },
                      child: Text(
                        "Mark all as read",
                        style: AppTextStyles.subtitle2(color: AppColors.blue),
                      ),
                    ),
                    AppSizes.xxxs.ph,
                    AppDropdown(
                      button: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.xxs,
                          vertical: AppSizes.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Row(
                          children: [
                            Text(
                              notificationState.selectedGroupId == null
                                  ? "All groups"
                                  : "Filtered",
                              style: AppTextStyles.caption2(
                                color: AppColors.black,
                              ),
                            ),
                            AppSizes.xxxs.pw,
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.arrowDown01,
                              color: AppColors.black,
                            ),
                          ],
                        ),
                      ),
                      items: [
                        AppDropdownItem(
                          value: "all",
                          label: 'All Groups',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: AppColors.white),
            AppSizes.xs.ph,
            
            // Loading State
            if (notificationState.isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                ),
              )
            
            // Error State
            else if (notificationState.isFailure)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColors.red),
                      AppSizes.md.ph,
                      Text(
                        "Failed to load notifications",
                        style: AppTextStyles.headline5(),
                      ),
                      AppSizes.xs.ph,
                      Text(
                        notificationState.error ?? "Unknown error",
                        style: AppTextStyles.bodyText2(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      AppSizes.md.ph,
                      AppButton(
                        label: "Retry",
                        onPressed: () => notifier.fetchNotifications(),
                        bgColor: AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ),
              )
            
            // Empty State
            else if (!notificationState.hasNotifications)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.notification01,
                        size: 64,
                        color: Colors.grey,
                      ),
                      AppSizes.md.ph,
                      Text(
                        "No notifications yet",
                        style: AppTextStyles.headline5(),
                      ),
                      AppSizes.xs.ph,
                      Text(
                        "You'll see notifications here when something happens",
                        style: AppTextStyles.bodyText2(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            
            // Notifications List
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => notifier.fetchNotifications(),
                  color: AppColors.primaryOrange,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final timeAgo = timeago.format(notification.createdAt);
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: notification.isRead 
                              ? AppColors.black 
                              : AppColors.darkBgContainer,
                          border: Border.all(
                            color: notification.isRead 
                                ? AppColors.borderBrown 
                                : AppColors.primaryOrange.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${_getNotificationIcon(notification.type)}${notification.title}",
                                      style: AppTextStyles.bodyText1().copyWith(
                                        fontWeight: notification.isRead 
                                            ? AppFontWeights.regular 
                                            : AppFontWeights.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      notifier.deleteNotification(notification.id);
                                    },
                                    child: HugeIcon(
                                      icon: HugeIconsStrokeRounded.delete02,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                              AppSizes.xxs.ph,
                              Text(
                                notification.body,
                                style: AppTextStyles.bodyText2(
                                  color: Colors.grey,
                                ),
                              ),
                              AppSizes.xxs.ph,
                              Row(
                                children: [
                                  Text(
                                    timeAgo,
                                    style: AppTextStyles.caption2(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (notification.groupId != null) ...[
                                    AppSizes.lg.pw,
                                    Text(
                                      "in group",
                                      style: AppTextStyles.caption2(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => AppSizes.xxxs.ph,
                    itemCount: notifications.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

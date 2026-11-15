import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/widgets/animated_list_item.dart';
import 'package:mediconsult/features/notifications/data/notification_models.dart';
import 'package:mediconsult/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mediconsult/features/notifications/presentation/widgets/notification_card.dart';
import 'package:mediconsult/features/notifications/presentation/widgets/notification_date_formatter.dart';

class NotificationsListView extends StatelessWidget {
  final List<NotificationItem> notifications;
  final ScrollController controller;
  final bool hasNextPage;
  final VoidCallback onRefresh;

  const NotificationsListView({
    super.key,
    required this.notifications,
    required this.controller,
    required this.hasNextPage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    final groupedNotifications = _groupByDate(notifications);
    final dates = groupedNotifications.keys.toList();

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollCacheExtent: ScrollCacheExtent.pixels(1000),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        padding: EdgeInsets.all(16.w),
        itemCount: dates.length + (hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= dates.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final date = dates[index];
          final dateNotifications = groupedNotifications[date]!;
          int itemIndex = 0;

          return AnimatedListItem(
            index: index,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(context, date, index),
                ...dateNotifications.map((notification) {
                  final currentItemIndex = itemIndex++;
                  return AnimatedListItem(
                    index: currentItemIndex,
                    delay: const Duration(milliseconds: 30),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: NotificationCard(
                        key: ValueKey('${notification.id}_${notification.isSeen}'),
                        item: notification,
                        onMarkRead: notification.isRead
                            ? null
                            : () => context.read<NotificationsCubit>().markAsRead(
                                  lang: context.locale.languageCode,
                                  notificationId: notification.id,
                                ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String date, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: index == 0 ? 0 : 16.h),
      child: Text(
        NotificationDateFormatter.formatDateHeader(context, date),
        style: AppTextStyles.font14BlackMedium(context),
      ),
    );
  }

  Map<String, List<NotificationItem>> _groupByDate(
      List<NotificationItem> notifications) {
    final Map<String, List<NotificationItem>> grouped = {};
    for (var notification in notifications) {
      if (!grouped.containsKey(notification.date)) {
        grouped[notification.date] = [];
      }
      grouped[notification.date]!.add(notification);
    }
    return grouped;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon with gradient background
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryClr.withValues(alpha: 0.1),
                    AppColors.primaryClr.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 48.sp,
                color: AppColors.primaryClr.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'notifications.no_notifications'.tr(),
              style: AppTextStyles.font16BlackMedium(context).copyWith(
                color: AppColors.blackClr.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'notifications.no_notifications_desc'.tr(),
              style: AppTextStyles.font14GreyRegular(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Pull to refresh hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 16.sp,
                  color: AppColors.greyClr,
                ),
                SizedBox(width: 8.w),
                Text(
                  'notifications.pull_to_refresh'.tr(),
                  style: AppTextStyles.font12GreyRegular(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/features/notifications/data/notification_models.dart';
import 'package:mediconsult/core/utils/notification_action_handler.dart';
import 'package:mediconsult/shared/widgets/status_badge.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onMarkRead;
  
  const NotificationCard({
    super.key,
    required this.item,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    final icon = _getIcon();
    final hasAction = NotificationActionHandler.hasAction(item);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (hasAction) {
            await NotificationActionHandler.handleNotificationTap(context, item);
          }
          if (!item.isRead && onMarkRead != null) {
            onMarkRead!();
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: item.isRead 
                ? AppColors.whiteClr 
                : statusInfo.color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: item.isRead
                  ? AppColors.greyClr.withValues(alpha: 0.2)
                  : statusInfo.color.withValues(alpha: 0.4),
              width: item.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with status color
              _buildIconContainer(icon, statusInfo.color),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with status badge and time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Status badge if approved or rejected
                        if (statusInfo.showBadge) ...[
                          StatusBadgeSmall(
                            label: statusInfo.label,
                            color: statusInfo.color,
                            icon: statusInfo.icon,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        // Unread indicator
                        if (!item.isRead)
                          Container(
                            width: 6.w,
                            height: 6.w,
                            margin: EdgeInsets.only(right: 6.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.greyClr,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Title - clear black text
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackClr,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // Body - darker text for readability
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.blackClr.withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Action arrow
              if (hasAction)
                Padding(
                  padding: EdgeInsets.only(top: 16.h, left: 4.w),
                  child: Icon(
                    isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: AppColors.greyClr,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    final hasValidImage = item.imageUrl != null && 
                          item.imageUrl!.trim().isNotEmpty &&
                          _isValidImageUrl(item.imageUrl!);
    
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: hasValidImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!.trim(),
                fit: BoxFit.cover,
                memCacheWidth: 88,
                memCacheHeight: 88,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(icon, color: color, size: 22.sp),
                ),
              ),
            )
          : Center(
              child: Icon(icon, color: color, size: 22.sp),
            ),
    );
  }
  
  bool _isValidImageUrl(String url) {
    try {
      final trimmedUrl = url.trim();
      if (trimmedUrl.isEmpty) return false;
      
      final lowerUrl = trimmedUrl.toLowerCase();
      
      if (!lowerUrl.startsWith('http://') && !lowerUrl.startsWith('https://')) {
        return false;
      }
      
      if (lowerUrl.contains('firebasestorage.googleapis.com') ||
          lowerUrl.contains('firebasestorage.app')) {
        return true;
      }
      
      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg'];
      for (final ext in imageExtensions) {
        if (lowerUrl.endsWith(ext)) return true;
      }
      
      if (lowerUrl.contains('/image/') ||
          lowerUrl.contains('/images/') ||
          lowerUrl.contains('/img/')) {
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  _StatusInfo _getStatusInfo() {
    final body = item.body.toLowerCase();
    final title = item.title.toLowerCase();
    final combined = '$body $title';
    
    // Check for rejected status FIRST (priority over approved)
    // "يؤسفنا" = we regret = rejection
    if (combined.contains('rejected') || 
        combined.contains('reject') ||
        combined.contains('مرفوض') ||
        combined.contains('رفض') ||
        combined.contains('الرفض') ||
        combined.contains('يؤسفنا') ||
        combined.contains('نأسف') ||
        combined.contains('للأسف') ||
        combined.contains('غير موافق') ||
        combined.contains('لم يتم')) {
      return _StatusInfo(
        color: const Color(0xFFD32F2F), // Dark red
        icon: Icons.cancel,
        label: 'Rejected',
        showBadge: true,
      );
    }
    
    // Check for approved status
    if (combined.contains('approved') || 
        combined.contains('موافق') ||
        combined.contains('تمت الموافقة') ||
        combined.contains('قبول') ||
        combined.contains('مقبول') ||
        combined.contains('يسعدنا') ||
        combined.contains('تم قبول')) {
      return _StatusInfo(
        color: const Color(0xFF2E7D32), // Dark green
        icon: Icons.check_circle,
        label: 'Approved',
        showBadge: true,
      );
    }
    
    // Check for pending/reviewing status
    if (combined.contains('pending') || 
        combined.contains('reviewing') ||
        combined.contains('جاري') ||
        combined.contains('قيد')) {
      return _StatusInfo(
        color: Colors.orange,
        icon: Icons.schedule,
        label: 'Pending',
        showBadge: false,
      );
    }
    
    // Default - primary color
    return _StatusInfo(
      color: AppColors.primaryClr,
      icon: Icons.notifications,
      label: '',
      showBadge: false,
    );
  }

  IconData _getIcon() {
    if (item.hasDataKeyValue('is_disable', '1')) {
      return Icons.person_off;
    }

    if (item.hasDataKeyValue('is_refund', '1')) {
      return Icons.receipt_long;
    }

    final approvalId = item.getDataValue('approval_id');
    final requestId = item.getDataValue('request_id');
    final isApproved = item.hasDataKeyValue('is_approved', '1');
    final hasApprovalOrRequest = (approvalId != null &&
            approvalId.isNotEmpty &&
            approvalId != '0') ||
        (requestId != null && requestId.isNotEmpty && requestId != '0');

    if (hasApprovalOrRequest || isApproved) {
      return Icons.assignment;
    }

    final body = item.body.toLowerCase();
    if (body.contains('appointment') || body.contains('موعد')) {
      return Icons.calendar_today;
    } else if (body.contains('medicine') || body.contains('دواء')) {
      return Icons.medication;
    }
    return Icons.notifications;
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;
  final bool showBadge;
  
  _StatusInfo({
    required this.color,
    required this.icon,
    required this.label,
    required this.showBadge,
  });
}

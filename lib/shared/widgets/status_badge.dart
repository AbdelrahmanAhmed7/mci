import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color statusColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.status,
    required this.statusColor,
    this.icon,
  });

  /// Factory constructor for approval/refund status
  factory StatusBadge.fromStatusChar({
    required String status,
    required String statusChar,
    required Color statusColor,
  }) {
    return StatusBadge(
      status: status,
      statusColor: statusColor,
      icon: _getIconFromStatus(status),
    );
  }

  static IconData _getIconFromStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'dispensed' || s == 'paid') {
      return Icons.done_all;
    } else if (s == 'approved') {
      return Icons.check;
    } else if (s == 'rejected' || s == 'canceled') {
      return Icons.close;
    } else if (s == 'pending' || s == 'reviewing') {
      return Icons.schedule;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _getIconFromStatus(status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              effectiveIcon,
              size: 12.sp,
              color: statusColor,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            status,
            style: AppTextStyles.font10WhiteRegular(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Smaller version for notifications
class StatusBadgeSmall extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusBadgeSmall({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 10.sp,
              color: color,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

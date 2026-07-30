import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/utils/date_formatter.dart';

class DateTimeRow extends StatelessWidget {
  final String date;
  final String? time;
  final Color iconColor;

  const DateTimeRow({
    super.key,
    required this.date,
    this.time,
    this.iconColor = AppColors.blueClr,
  });

  bool get _hasValidTime {
    return time != null && time!.isNotEmpty && time != "-1";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12.sp, color: iconColor),
        SizedBox(width: 4.w),
        Text(
          date,
          style: AppTextStyles.font10BlackMedium(context),
        ),
        if (_hasValidTime) ...[
          SizedBox(width: 10.w),
          Icon(Icons.access_time, size: 12.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            DateFormatter.formatTime(time!),
            style: AppTextStyles.font10BlackMedium(context),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';

/// A card widget for form sections with an icon and title
class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool isRequired;
  final bool hasError;
  final String? errorText;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final Color? backgroundColor;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.isRequired = false,
    this.hasError = false,
    this.errorText,
    this.padding,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: hasError 
                    ? AppColors.errorClr 
                    : (iconColor ?? AppColors.primaryClr),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.font14BlackMedium(context).copyWith(
                          color: hasError ? AppColors.errorClr : AppColors.blackClr,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isRequired) ...[
                      SizedBox(width: 4.w),
                      Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.errorClr,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
          if (hasError && errorText != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14.sp,
                  color: AppColors.errorClr,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    errorText!,
                    style: AppTextStyles.font12GreyRegular(context).copyWith(
                      color: AppColors.errorClr,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A minimal section header without card styling
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isRequired;
  final Color? iconColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.isRequired = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryClr).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: iconColor ?? AppColors.primaryClr,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.font14BlackMedium(context),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (isRequired) ...[
          SizedBox(width: 4.w),
          Text(
            '*',
            style: TextStyle(
              color: AppColors.errorClr,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

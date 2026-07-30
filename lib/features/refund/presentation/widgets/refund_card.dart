import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/features/refund/data/refund_list_models.dart';
import 'package:mediconsult/features/refund/repository/refund_repository.dart';
import 'package:mediconsult/core/di/service_locator.dart';
import 'package:mediconsult/core/utils/pdf_helper.dart';
import 'package:mediconsult/core/utils/status_helper.dart';
import 'package:mediconsult/shared/widgets/status_badge.dart';
import 'package:mediconsult/shared/widgets/provider_logo.dart';
import 'package:mediconsult/shared/widgets/date_time_row.dart';

class RefundCard extends StatelessWidget {
  final RefundItem item;
  
  const RefundCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = StatusHelper.getStatusColor(item.statusChar);
    final Color backgroundColor = StatusHelper.getBackgroundColor(item.statusChar);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProviderLogo(logoUrl: item.providerLogo),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Provider name + Status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.providerName,
                        style: AppTextStyles.font12BlackMedium(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    StatusBadge(
                      status: item.status,
                      statusColor: statusColor,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Refund number
                Text(
                  '${'refund_history.request_number'.tr()}${item.approvalNumber}',
                  style: AppTextStyles.font10GreyRegular(context),
                ),
                SizedBox(height: 4.h),
                // Date and Time
                DateTimeRow(date: item.date, time: item.time),
                // Amount if available
                if (item.totalAmount != null && item.totalAmount! > 0) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 12.sp, color: AppColors.blueClr),
                      SizedBox(width: 4.w),
                      Text(
                        '${item.totalAmount!.toStringAsFixed(2)} ${'common.egp'.tr()}',
                        style: AppTextStyles.font10BlackMedium(context),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 6.h),
                _buildViewDetailsButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _openRefundPdf(context),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'refund_history.view_details'.tr(),
          style: AppTextStyles.font12BlueMedium(context),
        ),
      ),
    );
  }

  Future<void> _openRefundPdf(BuildContext context) async {
    await PdfHelper.openPdf(
      context: context,
      fetchPdf: () => sl<RefundRepository>().getRefundPdf(
        lang: context.locale.languageCode,
        refundId: item.id,
      ),
      errorMessageKey: 'refund_history.cannot_open_pdf',
    );
  }
}
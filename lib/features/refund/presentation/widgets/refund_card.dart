import 'package:material_ui/material_ui.dart';
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
    final Color backgroundColor = StatusHelper.getBackgroundColor(
      item.statusChar,
    );
    final rejectReason = item.rejectReason?.trim() ?? '';

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
                    StatusBadge(status: item.status, statusColor: statusColor),
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
                      Icon(
                        Icons.payments_outlined,
                        size: 12.sp,
                        color: AppColors.blueClr,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${item.totalAmount!.toStringAsFixed(2)} ${'common.egp'.tr()}',
                        style: AppTextStyles.font10BlackMedium(context),
                      ),
                    ],
                  ),
                ],
                if (_shouldShowRejectReason(rejectReason)) ...[
                  SizedBox(height: 6.h),
                  _RejectReasonBox(
                    reason: rejectReason,
                    statusColor: statusColor,
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

  bool _shouldShowRejectReason(String reason) {
    if (reason.isEmpty) return false;
    final status = item.status.toLowerCase().trim();
    final statusChar = item.statusChar.toUpperCase().trim();
    return statusChar == 'R' ||
        statusChar == 'C' ||
        status == 'rejected' ||
        status == 'canceled' ||
        status == 'cancelled';
  }
}

class _RejectReasonBox extends StatelessWidget {
  final String reason;
  final Color statusColor;

  const _RejectReasonBox({required this.reason, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14.sp, color: statusColor),
          SizedBox(width: 6.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.font10GreyRegular(
                  context,
                ).copyWith(height: 1.35),
                children: [
                  TextSpan(
                    text: '${'refund_history.reject_reason'.tr()}: ',
                    style: AppTextStyles.font10BlackMedium(
                      context,
                    ).copyWith(color: statusColor),
                  ),
                  TextSpan(text: reason),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

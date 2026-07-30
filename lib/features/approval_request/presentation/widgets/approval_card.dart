import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/core/di/service_locator.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/features/approval_request/data/approvals_models.dart';
import 'package:mediconsult/features/approval_request/repository/approvals_repository.dart';
import 'package:mediconsult/core/utils/pdf_helper.dart';
import 'package:mediconsult/core/utils/status_helper.dart';
import 'package:mediconsult/shared/widgets/status_badge.dart';
import 'package:mediconsult/shared/widgets/provider_logo.dart';
import 'package:mediconsult/shared/widgets/date_time_row.dart';

class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  const ApprovalCard({super.key, required this.item});

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
                // Approval number
                Text(
                  '${'approval_history.request_number'.tr()}${item.approvalNumber}',
                  style: AppTextStyles.font10GreyRegular(context),
                ),
                SizedBox(height: 4.h),
                // Date and Time
                DateTimeRow(date: item.date, time: item.time),
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
        onPressed: () => _openApprovalPdf(context),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'approval_history.view_details'.tr(),
          style: AppTextStyles.font12BlueMedium(context),
        ),
      ),
    );
  }

  Future<void> _openApprovalPdf(BuildContext context) async {
    await PdfHelper.openPdf(
      context: context,
      fetchPdf: () => sl<ApprovalsRepository>().getApprovalPdf(
        lang: context.locale.languageCode,
        approvalId: item.id,
      ),
      errorMessageKey: 'approval_history.cannot_open_pdf',
    );
  }
}
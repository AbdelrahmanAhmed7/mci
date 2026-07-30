import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/features/approval_request/data/approvals_models.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/approval_card.dart';
import 'package:mediconsult/features/approval_request/presentation/cubit/approvals_cubit.dart';
import 'package:mediconsult/core/widgets/smooth_shimmer.dart';
import 'package:mediconsult/core/widgets/animated_list_item.dart';

class ApprovalListView extends StatelessWidget {
  final List<ApprovalItem> approvals;
  final ScrollController controller;
  final bool hasNextPage;

  const ApprovalListView({
    super.key,
    required this.approvals,
    required this.controller,
    required this.hasNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final lang = context.locale.languageCode;
        await context.read<ApprovalsCubit>().refreshApprovals(lang: lang);
      },
      child: ListView.separated(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: approvals.length + (hasNextPage ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index >= approvals.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const ShimmerApprovalCard(),
            );
          }
          return AnimatedListItem(
            index: index,
            child: ApprovalCard(
              key: ValueKey(approvals[index].id),
              item: approvals[index],
            ),
          );
        },
      ),
    );
  }
}

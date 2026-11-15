import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/widgets/smooth_shimmer.dart';
import 'package:mediconsult/core/widgets/error_state_widget.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/features/support/presentation/cubit/faq_cubit.dart';
import 'package:mediconsult/features/support/presentation/cubit/faq_state.dart';
import 'package:mediconsult/core/utils/language_helper.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String? _lastLanguageCode;
  int? _expandedIndex; // Track which FAQ is expanded

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = LanguageHelper.getLanguageCode(context);

    if (_lastLanguageCode == null || _lastLanguageCode != currentLang) {
      final isLanguageChange = _lastLanguageCode != null && _lastLanguageCode != currentLang;
      _lastLanguageCode = currentLang;

      if (isLanguageChange) {
        context.read<FaqCubit>().clearCache();
        _expandedIndex = null; // Reset expanded state on language change
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          if (isLanguageChange) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
          if (mounted) {
            context.read<FaqCubit>().load(
              lang: currentLang,
              forceRefresh: true,
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyClr,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: 'profile.faq.title'.tr(), backPath: '/profile'),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -20.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteClr,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyClr.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: BlocBuilder<FaqCubit, FaqState>(
                      builder: (context, state) {
                        return state.when(
                          initial: () => _buildShimmerList(),
                          loading: () => _buildShimmerList(),
                          failed: (message) => _buildErrorState(message),
                          loaded: (faqResponse) {
                            final data = faqResponse.data.faqs;
                            return ListView.separated(
                              padding: EdgeInsets.all(16.w),
                              itemCount: data.length,
                              separatorBuilder: (context, index) => SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final faq = data[index];
                                final isExpanded = _expandedIndex == index;

                                return _buildFAQItem(
                                  faq: faq,
                                  isExpanded: isExpanded,
                                  onTap: () {
                                    setState(() {
                                      _expandedIndex = isExpanded ? null : index;
                                    });
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required dynamic faq,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isExpanded
              ? AppColors.primaryClr.withValues(alpha: 0.3)
              : AppColors.greyClr.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.primaryClr.withValues(alpha: 0.08)
                : AppColors.greyClr.withValues(alpha: 0.06),
            blurRadius: isExpanded ? 20 : 12,
            offset: Offset(0, isExpanded ? 6 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon indicator
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? AppColors.primaryClr.withValues(alpha: 0.1)
                            : AppColors.greyClr.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 18.sp,
                        color: isExpanded
                            ? AppColors.primaryClr
                            : AppColors.greyClr,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Question text
                    Expanded(
                      child: Text(
                        faq.question,
                        style: AppTextStyles.font14BlackMedium(context).copyWith(
                          color: isExpanded ? AppColors.primaryClr : AppColors.blackClr,
                          fontSize: 15.sp,
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Arrow icon
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24.sp,
                        color: isExpanded
                            ? AppColors.primaryClr
                            : AppColors.greyClr,
                      ),
                    ),
                  ],
                ),

                // Answer - animated
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(
                      top: 16.h,
                      left: 44.w, // Align with question text (icon width + spacing)
                    ),
                    child: Text(
                      faq.answer,
                      style: AppTextStyles.font14GreyRegular(context).copyWith(
                        height: 1.6,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => ShimmerCard(
          height: 80.h,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: ErrorStateWidget(
          error: message,
          onRetry: () => context.read<FaqCubit>().load(
            lang: LanguageHelper.getLanguageCode(context),
            forceRefresh: true,
          ),
        ),
      ),
    );
  }
}
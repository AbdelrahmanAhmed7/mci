import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/services/haptic_feedback_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/shared/widgets/coming_soon_dialog.dart';

class QuickAccessWidget extends StatelessWidget {
  const QuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            'home.quick_access'.tr(),
            style: AppTextStyles.font14BlackMedium(context).copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadowClr,
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuickAccessButton(
                image: AppAssets.approval,
                label: 'home.approval'.tr(),
                color: AppColors.approvalColor,
                textColor: AppColors.approvalTextColor,
                gradientColors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                onTap: () {
                  context.push('/approval-history');
                },
              ),
              _QuickAccessButton(
                image: AppAssets.refund,
                label: 'home.refund'.tr(),
                color: AppColors.refundColor,
                textColor: AppColors.refundTextColor,
                gradientColors: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                onTap: () {
                  context.push('/refund-history');
                },
              ),
              _QuickAccessButton(
                image: AppAssets.medicine,
                label: 'home.chronic_medicine'.tr(),
                color: AppColors.chronicMedicineColor,
                textColor: AppColors.chronicMedicineTextColor,
                gradientColors: const [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
                onTap: () {
                  ComingSoonDialog.show(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAccessButton extends StatefulWidget {
  final String image;
  final String label;
  final Color color;
  final Color textColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.image,
    required this.label,
    required this.color,
    required this.textColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<_QuickAccessButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedbackService.instance.lightImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(
                          alpha: 0.5 * _shadowAnimation.value,
                        ),
                        blurRadius: 12 * _shadowAnimation.value,
                        offset: Offset(0, 6 * _shadowAnimation.value),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.image,
                      width: 42.w,
                      height: 42.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font12GreyRegular(context).copyWith(
                    color: widget.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

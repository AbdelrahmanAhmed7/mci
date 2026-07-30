import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/services/haptic_feedback_service.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.backPath,
    this.onHelp,
    this.useGradient = true,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final String? backPath;
  final VoidCallback? onHelp;
  final bool useGradient;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      height: 136.h,
      decoration: BoxDecoration(
        gradient: useGradient ? AppColors.primaryGradient : null,
        color: useGradient ? null : AppColors.primaryClr,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(4.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadowClr,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles for depth
          Positioned(
            top: -20.h,
            right: isRtl ? null : -30.w,
            left: isRtl ? -30.w : null,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40.h,
            left: isRtl ? null : -20.w,
            right: isRtl ? -20.w : null,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back button
                Align(
                  alignment:
                      isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  child: _AnimatedBackButton(
                    onTap: onBack ??
                        () {
                          if (Navigator.of(context).canPop()) {
                            context.pop();
                          } else if (backPath != null) {
                            context.go(backPath!);
                          } else {
                            context.go('/home');
                          }
                        },
                  ),
                ),

                // Title with animation
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 56.w),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font18BlackSemiBold(context)
                            .copyWith(
                          color: AppColors.whiteClr,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),

                // Help button or actions
                if (onHelp != null || actions != null)
                  Align(
                    alignment:
                        isRtl ? Alignment.centerLeft : Alignment.centerRight,
                    child: actions != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!,
                          )
                        : _AnimatedHelpButton(
                            onTap: onHelp!,
                            isRtl: isRtl,
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.onTap});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedbackService.instance.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.whiteClr,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.primaryClr,
          ),
        ),
      ),
    );
  }
}

class _AnimatedHelpButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isRtl;

  const _AnimatedHelpButton({
    required this.onTap,
    required this.isRtl,
  });

  @override
  State<_AnimatedHelpButton> createState() => _AnimatedHelpButtonState();
}

class _AnimatedHelpButtonState extends State<_AnimatedHelpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedbackService.instance.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(widget.isRtl ? math.pi : 0),
            child: Icon(
              CupertinoIcons.question,
              color: AppColors.whiteClr,
              size: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}

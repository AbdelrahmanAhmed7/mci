import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';

/// Enhanced empty state widget with animations
class EmptyStateWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final Color? iconColor;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.action,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _messageAnimation;
  late Animation<double> _actionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _actionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconAnimation.value,
                  child: Opacity(
                    opacity: _iconAnimation.value,
                    child: Icon(
                      widget.icon,
                      size: 80.w,
                      color: widget.iconColor ?? AppColors.greyClr,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),

            // Title
            if (widget.title != null)
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleAnimation.value,
                    child: Text(
                      widget.title!,
                      style: AppTextStyles.font18BlackSemiBold(context),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

            // Message
            if (widget.message != null) ...[
              SizedBox(height: 8.h),
              AnimatedBuilder(
                animation: _messageAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _messageAnimation.value,
                    child: Text(
                      widget.message!,
                      style: AppTextStyles.font14GreyRegular(context),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],

            // Action Button
            if (widget.action != null ||
                (widget.actionLabel != null && widget.onAction != null)) ...[
              SizedBox(height: 24.h),
              AnimatedBuilder(
                animation: _actionAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _actionAnimation.value,
                    child: widget.action ??
                        ElevatedButton(
                          onPressed: widget.onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryClr,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(widget.actionLabel!),
                        ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for lists
class EmptyListWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const EmptyListWidget({
    super.key,
    this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'common.no_data'.tr(),
      message: message ?? 'common.no_data_available'.tr(),
      icon: Icons.list_alt_outlined,
      actionLabel: onRefresh != null ? 'common.refresh'.tr() : null,
      onAction: onRefresh,
    );
  }
}


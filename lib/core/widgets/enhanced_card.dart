import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/services/haptic_feedback_service.dart';

/// Enhanced card widget with improved shadows, gradients, and press animations.
class EnhancedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final bool enablePressAnimation;
  final bool enableHaptic;
  final Border? border;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.enablePressAnimation = true,
    this.enableHaptic = true,
    this.border,
  });

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
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
    if (widget.onTap != null && widget.enablePressAnimation) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.enablePressAnimation) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && widget.enablePressAnimation) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedbackService.instance.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(16.r);
    final effectiveBorderRadius = widget.borderRadius ?? defaultBorderRadius;

    final defaultShadow = [
      BoxShadow(
        color: AppColors.cardShadowClr,
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: AppColors.cardShadowClr.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
    ];

    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.gradient == null
            ? (widget.backgroundColor ?? AppColors.whiteClr)
            : null,
        gradient: widget.gradient,
        borderRadius: effectiveBorderRadius,
        border: widget.border,
      ),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          boxShadow: widget.boxShadow ?? defaultShadow,
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enablePressAnimation ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              boxShadow: (widget.boxShadow ?? defaultShadow).map((shadow) {
                return BoxShadow(
                  color: shadow.color.withValues(
                    alpha: shadow.color.a * _shadowAnimation.value,
                  ),
                  blurRadius: shadow.blurRadius * _shadowAnimation.value,
                  offset: shadow.offset * _shadowAnimation.value,
                  spreadRadius: shadow.spreadRadius,
                );
              }).toList(),
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      ),
    );
  }
}

/// Preset card styles for common use cases
class CardPresets {
  /// Default elevated card
  static EnhancedCard elevated({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return EnhancedCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Flat card with subtle border
  static EnhancedCard flat({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return EnhancedCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      boxShadow: const [],
      border: Border.all(color: AppColors.borderClr, width: 1),
      child: child,
    );
  }

  /// Gradient card with primary colors
  static EnhancedCard gradient({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return EnhancedCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      gradient: AppColors.primaryGradient,
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryShadowClr,
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: child,
    );
  }

  /// Success card with green gradient
  static EnhancedCard success({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return EnhancedCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      gradient: AppColors.successGradient,
      boxShadow: [
        BoxShadow(
          color: AppColors.successShadowClr,
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: child,
    );
  }
}

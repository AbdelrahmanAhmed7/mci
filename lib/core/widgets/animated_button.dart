import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/services/haptic_feedback_service.dart';

/// Animated button with haptic feedback and micro-interactions
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final Duration animationDuration;
  final double scaleOnPress;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.animationDuration = const Duration(milliseconds: 80),
    this.scaleOnPress = 0.88,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnPress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails? details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails? details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticFeedbackType.light:
        HapticFeedbackService.instance.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedbackService.instance.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedbackService.instance.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedbackService.instance.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: widget.onPressed != null
          ? () {
              if (widget.enableHaptic) {
                _triggerHaptic();
              }
              widget.onPressed!();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        padding: widget.padding ??
            EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 12.h,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(8),
        ),
        elevation: widget.elevation ?? 2,
      ),
      child: widget.child,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: (_) => _handleTapUp(null),
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: button,
      ),
    );
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}


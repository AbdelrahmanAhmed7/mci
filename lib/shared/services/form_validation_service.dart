import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Service for form validation with scroll-to-error functionality
class FormValidationService {
  /// Scroll to the first field that has an error
  static Future<void> scrollToFirstError({
    required ScrollController scrollController,
    required List<GlobalKey> fieldKeys,
    required List<bool> hasErrors,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeInOut,
    double offset = 100,
  }) async {
    for (int i = 0; i < fieldKeys.length; i++) {
      if (i < hasErrors.length && hasErrors[i]) {
        await scrollToField(
          scrollController: scrollController,
          fieldKey: fieldKeys[i],
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          offset: offset,
        );
        
        // Trigger haptic feedback
        HapticFeedback.lightImpact();
        break;
      }
    }
  }

  /// Scroll to a specific field
  static Future<void> scrollToField({
    required ScrollController scrollController,
    required GlobalKey fieldKey,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeInOut,
    double offset = 100,
  }) async {
    final context = fieldKey.currentContext;
    if (context == null) return;

    // Get the RenderObject of the field
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    // Get the position of the field relative to the scroll view
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState == null) return;

    final position = scrollableState.position;
    final renderBox = renderObject as RenderBox;
    
    // Calculate the offset to scroll to
    final fieldOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableState.context.findRenderObject(),
    );
    
    final targetOffset = position.pixels + fieldOffset.dy - offset;
    
    // Clamp to valid scroll range
    final clampedOffset = targetOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    await scrollController.animateTo(
      clampedOffset,
      duration: animationDuration,
      curve: animationCurve,
    );
  }

  /// Shake animation for error indication
  static void shakeField(GlobalKey fieldKey) {
    final context = fieldKey.currentContext;
    if (context == null) return;

    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
  }

  /// Validate a list of conditions and return the index of first error
  static int? findFirstErrorIndex(List<bool> conditions) {
    for (int i = 0; i < conditions.length; i++) {
      if (!conditions[i]) {
        return i;
      }
    }
    return null;
  }
}

/// A widget that wraps a form field and provides error animation
class AnimatedErrorField extends StatefulWidget {
  final Widget child;
  final bool hasError;
  final Duration shakeDuration;

  const AnimatedErrorField({
    super.key,
    required this.child,
    this.hasError = false,
    this.shakeDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedErrorField> createState() => _AnimatedErrorFieldState();
}

class _AnimatedErrorFieldState extends State<AnimatedErrorField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.shakeDuration,
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedErrorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _controller.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Extension to make validation easier
extension FormValidationExtension on GlobalKey<FormState> {
  bool validateAndSave() {
    final form = currentState;
    if (form == null) return false;
    
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}

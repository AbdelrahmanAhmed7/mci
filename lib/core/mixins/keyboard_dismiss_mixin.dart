import 'package:material_ui/material_ui.dart';

mixin KeyboardDismissMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  FocusNode? _currentFocusNode;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currentFocusNode?.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Check if keyboard is visible
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final wasKeyboardVisible = _isKeyboardVisible;
    _isKeyboardVisible = bottomInset > 0;

    // If keyboard was just dismissed, unfocus any focused field
    if (wasKeyboardVisible && !_isKeyboardVisible) {
      _dismissKeyboard();
    }
  }

  /// Dismiss keyboard and unfocus current field
  void _dismissKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild?.unfocus();
    } else {
      currentFocus.unfocus();
    }
  }

  /// Dismiss keyboard programmatically
  void dismissKeyboard() {
    _dismissKeyboard();
  }

  /// Check if keyboard is currently visible
  bool get isKeyboardVisible => _isKeyboardVisible;

  /// Wrap your scaffold body with this to enable tap-to-dismiss
  Widget buildKeyboardDismissible({
    required Widget child,
    bool dismissOnTap = true,
  }) {
    if (!dismissOnTap) {
      return child;
    }

    return GestureDetector(
      onTap: () {
        // Only dismiss if keyboard is visible
        if (_isKeyboardVisible) {
          _dismissKeyboard();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

/// Extension to easily use keyboard dismiss in Scaffold
extension KeyboardDismissExtension on Widget {
  /// Wrap widget with keyboard dismiss functionality
  Widget withKeyboardDismiss({
    bool dismissOnTap = true,
  }) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            if (dismissOnTap) {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                currentFocus.focusedChild?.unfocus();
              } else {
                currentFocus.unfocus();
              }
            }
          },
          behavior: HitTestBehavior.opaque,
          child: this,
        );
      },
    );
  }
}

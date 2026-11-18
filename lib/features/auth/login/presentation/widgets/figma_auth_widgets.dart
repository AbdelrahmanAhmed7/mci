import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediconsult/core/theming/figma_colors.dart';

const _authBackground = FigmaColors.blue25;
const _authBlue = FigmaColors.blue500;

class FigmaAuthPage extends StatefulWidget {
  final Widget child;

  const FigmaAuthPage({super.key, required this.child});

  @override
  State<FigmaAuthPage> createState() => _FigmaAuthPageState();
}

class _FigmaAuthPageState extends State<FigmaAuthPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _authBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _authBackground,
        body: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 430,
              height: 932,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 4,
                    left: 100,
                    width: 230,
                    height: 230,
                    child: Image.asset(
                      'assets/onboarding/figma/welcome_top.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FigmaAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? helperText;

  const FigmaAuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.helperText,
  });

  @override
  State<FigmaAuthTextField> createState() => _FigmaAuthTextFieldState();
}

class _FigmaAuthTextFieldState extends State<FigmaAuthTextField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 397,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: const TextStyle(fontSize: 16, color: FigmaColors.neutral900),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          helperStyle: const TextStyle(
            color: FigmaColors.neutral500,
            fontSize: 12,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: FigmaColors.neutral200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: FigmaColors.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _authBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(
                    _hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class FigmaAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const FigmaAuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 397,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _authBlue,
          disabledBackgroundColor: _authBlue.withValues(alpha: .55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class FigmaAuthTitle extends StatelessWidget {
  final String title;
  final String description;

  const FigmaAuthTitle({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 313,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: FigmaColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              color: FigmaColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

class FigmaAuthBackLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const FigmaAuthBackLink({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(text, style: const TextStyle(color: _authBlue, fontSize: 15)),
  );
}

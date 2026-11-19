import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/figma_colors.dart';

const _authBackground = FigmaColors.blue25;
const _authBlue = FigmaColors.blue500;
const _accountBackground = Color(0xFFFAFBFF);

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
                  DefaultTextStyle(
                    style: const TextStyle(fontFamily: 'Inter'),
                    child: widget.child,
                  ),
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
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: FigmaColors.neutral900,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: FigmaColors.neutral400,
          ),
          helperText: widget.helperText,
          helperStyle: const TextStyle(
            fontFamily: 'Inter',
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
                  fontFamily: 'Inter',
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
              fontFamily: 'Inter',
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
              fontFamily: 'Inter',
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

class FigmaAccountPage extends StatefulWidget {
  final String step;
  final Widget child;
  final VoidCallback onBack;

  const FigmaAccountPage({
    super.key,
    required this.step,
    required this.child,
    required this.onBack,
  });

  @override
  State<FigmaAccountPage> createState() => _FigmaAccountPageState();
}

class _FigmaAccountPageState extends State<FigmaAccountPage> {
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
        systemNavigationBarColor: _accountBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _accountBackground,
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
                    top: 58,
                    left: 0,
                    width: 430,
                    height: 76,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        // The title and step text together need about 49 px.
                        // Keep the top offset from the Figma layout while
                        // leaving enough room for both lines.
                        bottom: 10,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            height: 36,
                            child: IconButton(
                              onPressed: widget.onBack,
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 24,
                                top: 8,
                                bottom: 8,
                              ),
                              alignment: Alignment.centerLeft,
                              icon: Image.asset(
                                AppAssets.accountBack,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create account',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: FigmaColors.neutral900,
                                ),
                              ),
                              Text(
                                widget.step,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(fontFamily: 'Inter'),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FigmaProgress extends StatelessWidget {
  final int activeStep;
  const FigmaProgress({super.key, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 21,
      top: 150,
      width: 388,
      height: 4,
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
              decoration: BoxDecoration(
                color: index < activeStep ? _authBlue : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class FigmaAccountCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconAsset;
  final bool recommended;
  final VoidCallback onTap;

  const FigmaAccountCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 388,
      // The recommended card's description wraps to two lines beside the
      // badge, so the original 83 px height was not enough for its content.
      height: 93,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: recommended ? const Color(0xFFEBF3FF) : Colors.white,
        border: Border.all(
          color: recommended
              ? const Color(0xFFA7C8FF)
              : const Color(0x4DC4C6D0),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Image.asset(
              iconAsset,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          if (recommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _authBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'RECOMMENDED',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

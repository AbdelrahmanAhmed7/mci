import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/constants/constants.dart';
import 'package:mediconsult/core/theming/figma_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 900), _continue);
  }

  void _continue() {
    if (!mounted) return;

    final destination = isLoggedInUser
        ? '/home'
        : shouldShowOnboarding
        ? '/onboarding'
        : '/login';

    context.go(destination);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: FigmaColors.blue100,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [FigmaColors.white, FigmaColors.blue100],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Image.asset(
                'assets/logo/Logo.png',
                width: 365.w,
                fit: BoxFit.contain,
                semanticLabel: 'MediConsult',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

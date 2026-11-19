import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/constants/app_assets.dart';

class AccountVerifiedScreen extends StatelessWidget {
  const AccountVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFAFBFF),
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 430,
            height: 932,
            child: Stack(
              children: [
                Positioned(
                  top: 199,
                  left: 67,
                  width: 296,
                  child: Column(
                    children: [
                      const Text(
                        'Account Created\nSuccessfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          height: 34 / 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF092324),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'You can now sign in and start using\nyour MediConsult benefits.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.068,
                          height: 22.954 / 16.068,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 346,
                  left: 0,
                  width: 430,
                  child: Image.asset(
                    AppAssets.accountCreatedSuccess,
                    width: 430,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

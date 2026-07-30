// 🚀 PROD ENTRY POINT
// Run with:    flutter run --flavor prod --debug
//              (IMPORTANT: use --debug to see logs in console!)
//
// For RELEASE build (no logs, optimized):
//              flutter run --flavor prod --release
// or:          flutter build apk --flavor prod
//
// ⚠️  NOTE: Running WITHOUT --debug flag defaults to RELEASE mode
//           which strips ALL print() and debugPrint() output!
//           Always add --debug when you need to see logs.

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediconsult/core/constants/constants.dart';
import 'package:mediconsult/core/di/service_locator.dart';
import 'package:mediconsult/core/helpers/extension.dart';
import 'package:mediconsult/core/helpers/shared_pref_helper.dart';
import 'package:mediconsult/core/network/connectivity_service.dart';
import 'package:mediconsult/core/services/app_update_service.dart';
import 'package:mediconsult/core/services/firebase_crashlytics_service.dart';
import 'package:mediconsult/core/services/firebase_token_service.dart';
import 'package:mediconsult/features/notifications/service/push_notifications_service.dart';
import 'package:mediconsult/firebase_options.dart';
import 'package:mediconsult/mediconsult_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];

  // This log only shows in debug/profile mode, not in release
  debugPrint('🚀 [PROD] App starting... mode: ${kDebugMode ? "DEBUG" : kProfileMode ? "PROFILE" : "RELEASE"}');

  await _clearDataOnReinstall();

  await Future.wait<void>([
    EasyLocalization.ensureInitialized(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  await FirebaseCrashlyticsService.instance.initialize();
  await FirebaseCrashlyticsService.instance.log('PROD App started - ${DateTime.now()}');

  // Only send test crash error in release/prod builds (not during debug)
  if (!kDebugMode) {
    await FirebaseCrashlyticsService.instance.sendTestError();
  }

  await ConnectivityService.instance.initialize();
  await PushNotificationService.instance.initialize();

  await Future.wait<void>([
    setupServiceLocator(),
    checkIfLoggedInUser(),
    checkOnboardingStatus(),
  ]);

  // Check for app updates only in release mode on Android
  if (!kDebugMode) {
    Future.delayed(const Duration(seconds: 2), () {
      AppUpdateService.instance.checkForUpdate(forceUpdate: true).catchError((error) {
        debugPrint('[PROD] AppUpdateService error: $error');
      });
    });
  }

  if (isLoggedInUser) {
    final savedLocale = await SharedPrefHelper.getString('locale');
    final lang = savedLocale.isEmpty ? 'ar' : savedLocale;
    FirebaseTokenService.instance.sendTokenToBackend(lang);
    FirebaseTokenService.instance.listenToTokenRefresh(lang);
  }

  final savedLocale = await SharedPrefHelper.getString('locale');
  const supportedLocales = [Locale('en'), Locale('ar')];

  Locale startLocale;
  if (savedLocale.isNotEmpty) {
    startLocale = Locale(savedLocale);
  } else {
    final deviceLocale = PlatformDispatcher.instance.locale;
    startLocale = supportedLocales.firstWhere(
      (l) => l.languageCode == deviceLocale.languageCode,
      orElse: () => const Locale('en'),
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      useOnlyLangCode: true,
      saveLocale: true,
      child: const MediConsultApp(),
    ),
  );
}

checkIfLoggedInUser() async {
  String? userToken = await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
  isLoggedInUser = !userToken.isNullOrEmpty();
}

checkOnboardingStatus() async {
  final hasSeen = await SharedPrefHelper.getBool(SharedPrefKeys.hasSeenOnboarding);
  shouldShowOnboarding = !hasSeen;
  debugPrint('[PROD] Onboarding: hasSeen=$hasSeen, shouldShow=$shouldShowOnboarding');
}

Future<void> _clearDataOnReinstall() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'app_installed_before';
  final hasInstalledBefore = prefs.getBool(key) ?? false;
  if (!hasInstalledBefore) {
    await SharedPrefHelper.clearAllSecuredData();
    await SharedPrefHelper.clearAllData();
    await prefs.setBool(key, true);
    debugPrint('[PROD] First launch after install — cleared all cached data');
  }
}

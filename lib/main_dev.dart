// 🔧 DEV ENTRY POINT
// Run with: flutter run --flavor dev --debug
// or:       flutter run --flavor dev  (defaults to debug)
//
// This entry point enables all debug features:
// - Full console logging (print, debugPrint)
// - PrettyDioLogger showing every request/response
// - NO Crashlytics test errors sent
// - Update check disabled

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/constants/constants.dart';
import 'package:mediconsult/core/di/service_locator.dart';
import 'package:mediconsult/core/helpers/extension.dart';
import 'package:mediconsult/core/helpers/shared_pref_helper.dart';
import 'package:mediconsult/core/network/connectivity_service.dart';
import 'package:mediconsult/core/helpers/runtime_platform.dart';
import 'package:mediconsult/core/services/firebase_crashlytics_service.dart';
import 'package:mediconsult/core/services/firebase_token_service.dart';
import 'package:mediconsult/features/notifications/service/push_notifications_service.dart';
import 'package:mediconsult/firebase_options.dart';
import 'package:mediconsult/mediconsult_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];

  debugPrint('🚀 [DEV] App starting...');

  await _clearDataOnReinstall();

  await EasyLocalization.ensureInitialized();
  if (!isIntelIosSimulator) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseCrashlyticsService.instance.initialize();
    await FirebaseCrashlyticsService.instance.log(
      'DEV App started - ${DateTime.now()}',
    );
  }
  // Do NOT send test crash in dev to keep logs clean

  await ConnectivityService.instance.initialize();
  if (!isIntelIosSimulator) {
    await PushNotificationService.instance.initialize();
  }

  await Future.wait<void>([
    setupServiceLocator(),
    checkIfLoggedInUser(),
    checkOnboardingStatus(),
  ]);

  if (isLoggedInUser && !isIntelIosSimulator) {
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

  debugPrint('🌐 [DEV] Locale: $startLocale');
  debugPrint('👤 [DEV] isLoggedInUser: $isLoggedInUser');

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
  String? userToken = await SharedPrefHelper.getSecuredString(
    SharedPrefKeys.userToken,
  );
  isLoggedInUser = !userToken.isNullOrEmpty();
}

checkOnboardingStatus() async {
  final hasSeen = await SharedPrefHelper.getBool(
    SharedPrefKeys.hasSeenOnboarding,
  );
  shouldShowOnboarding = !hasSeen;
  debugPrint(
    '[DEV] Onboarding: hasSeen=$hasSeen, shouldShow=$shouldShowOnboarding',
  );
}

Future<void> _clearDataOnReinstall() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'app_installed_before';
  final hasInstalledBefore = prefs.getBool(key) ?? false;
  if (!hasInstalledBefore) {
    await SharedPrefHelper.clearAllSecuredData();
    await SharedPrefHelper.clearAllData();
    await prefs.setBool(key, true);
    debugPrint('[DEV] First launch after install — cleared all cached data');
  }
}

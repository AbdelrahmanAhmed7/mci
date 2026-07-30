import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:mediconsult/core/services/firebase_crashlytics_service.dart';

class AnalyticsService {
  // Singleton Pattern
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get Firebase Analytics Observer for automatic route tracking
  /// Add this to MaterialApp's navigatorObservers
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
      );

  // ============= Core Methods =============

  /// Logs a custom event with optional parameters.
  ///
  /// Event names should be snake_case and max 40 characters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Event: $name, Params: $parameters');
      }
    } catch (e, stack) {
      _handleError('logEvent', e, stack, additionalInfo: 'Event: $name');
    }
  }

  /// Sets the current screen name, which specifies the current visual context in your app.
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClassOverride ?? screenName,
      );
      if (kDebugMode) {
        debugPrint('📱 [Analytics] Screen: $screenName');
      }
    } catch (e, stack) {
      _handleError('setCurrentScreen', e, stack, additionalInfo: 'Screen: $screenName');
    }
  }

  // ============= Authentication Events =============

  /// Logs the standard `login` event.
  Future<void> logLogin({String? method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      if (kDebugMode) {
        debugPrint('🔐 [Analytics] Login: Method=$method');
      }
    } catch (e, stack) {
      _handleError('logLogin', e, stack);
    }
  }

  /// Logs the standard `sign_up` event.
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      if (kDebugMode) {
        debugPrint('📝 [Analytics] SignUp: Method=$method');
      }
    } catch (e, stack) {
      _handleError('logSignUp', e, stack);
    }
  }

  /// Logs logout event.
  Future<void> logLogout() async {
    await logEvent(name: 'logout');
  }

  // ============= User Properties =============

  /// Sets the user ID property.
  /// 
  /// ⚠️ IMPORTANT: Never log actual user IDs in debug mode for privacy!
  Future<void> setUserId(String? id) async {
    try {
      await _analytics.setUserId(id: id);
      if (kDebugMode) {
        // Don't log actual ID for privacy/security
        debugPrint('👤 [Analytics] User ID set: ${id != null ? "***" : "null"}');
      }
    } catch (e, stack) {
      _handleError('setUserId', e, stack);
    }
  }

  /// Sets a user property to a given value.
  ///
  /// User properties are attributes you define to describe segments of your user base.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        debugPrint('👤 [Analytics] User Property: $name = $value');
      }
    } catch (e, stack) {
      _handleError('setUserProperty', e, stack, additionalInfo: 'Property: $name');
    }
  }

  // ============= Medical App Specific Events =============

  /// Logs when user views their medical records.
  Future<void> logMedicalRecordViewed({
    required String recordType,
    String? recordId,
  }) async {
    await logEvent(
      name: 'medical_record_viewed',
      parameters: {
        'record_type': recordType,
        if (recordId != null) 'record_id': recordId,
      },
    );
  }

  /// Logs when user views chronic medicine details.
  Future<void> logChronicMedicineViewed({
    required String medicineId,
    required String medicineName,
  }) async {
    await logEvent(
      name: 'chronic_medicine_viewed',
      parameters: {
        'medicine_id': medicineId,
        'medicine_name': medicineName,
      },
    );
  }

  /// Logs when user views a prescription.
  Future<void> logPrescriptionViewed({
    required String prescriptionId,
  }) async {
    await logEvent(
      name: 'prescription_viewed',
      parameters: {
        'prescription_id': prescriptionId,
      },
    );
  }

  /// Logs when user requests a refund.
  Future<void> logRefundRequested({
    required String claimId,
    required double amount,
  }) async {
    await logEvent(
      name: 'refund_requested',
      parameters: {
        'claim_id': claimId,
        'amount': amount,
      },
    );
  }

  /// Logs when user submits an approval request.
  Future<void> logApprovalRequested({
    required String serviceType,
    String? providerId,
  }) async {
    await logEvent(
      name: 'approval_requested',
      parameters: {
        'service_type': serviceType,
        if (providerId != null) 'provider_id': providerId,
      },
    );
  }

  // ============= Family Member Events =============

  /// Logs when user adds a family member.
  Future<void> logFamilyMemberAdded({
    required String relation,
  }) async {
    await logEvent(
      name: 'family_member_added',
      parameters: {'relation': relation},
    );
  }

  // ============= Provider/Network Events =============

  /// Logs when user views a provider details.
  Future<void> logProviderViewed({
    required String providerId,
    required String providerName,
    required String specialty,
  }) async {
    await logEvent(
      name: 'provider_viewed',
      parameters: {
        'provider_id': providerId,
        'provider_name': providerName,
        'specialty': specialty,
      },
    );
  }

  /// Logs when user contacts a provider (call, location, etc).
  Future<void> logProviderContacted({
    required String providerId,
    required String method, // 'phone', 'location'
  }) async {
    await logEvent(
      name: 'provider_contacted',
      parameters: {
        'provider_id': providerId,
        'method': method,
      },
    );
  }

  // ============= Support & Profile Events =============

  /// Logs when user contacts support.
  Future<void> logSupportContacted({
    required String type, // 'call', 'email', 'ticket'
  }) async {
    await logEvent(
      name: 'support_contacted',
      parameters: {'type': type},
    );
  }

  /// Logs when user changes language.
  Future<void> logLanguageChanged({
    required String language,
  }) async {
    await logEvent(
      name: 'language_changed',
      parameters: {'language': language},
    );
  }

  /// Logs when user changes password.
  Future<void> logPasswordChanged() async {
    await logEvent(name: 'password_changed');
  }

  /// Logs search queries.
  Future<void> logSearch({
    required String searchTerm,
    required String searchCategory,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        parameters: {'category': searchCategory},
      );
      if (kDebugMode) {
        debugPrint('� [Analytics] Search: $searchTerm in $searchCategory');
      }
    } catch (e, stack) {
      _handleError('logSearch', e, stack);
    }
  }

  // ============= Plan/Subscription Events =============

  /// Logs when user views a plan/subscription.
  Future<void> logPlanViewed({
    required String planName,
    required String planId,
  }) async {
    await logEvent(
      name: 'plan_viewed',
      parameters: {
        'plan_name': planName,
        'plan_id': planId,
      },
    );
  }

  /// Logs when user subscribes to a plan.
  Future<void> logPlanSubscribed({
    required String planName,
    required String planId,
    required double price,
    String currency = 'EGP',
  }) async {
    await logEvent(
      name: 'plan_subscribed',
      parameters: {
        'plan_name': planName,
        'plan_id': planId,
        'price': price,
        'currency': currency,
      },
    );
  }

  // ============= Error Tracking =============

  /// Logs app errors for analytics tracking.
  Future<void> logAppError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (screenName != null) 'screen': screenName,
      },
    );
  }

  // ============= Helper Methods =============

  /// Centralized error handling for analytics failures.
  void _handleError(
    String method,
    Object exception,
    StackTrace stackTrace, {
    String? additionalInfo,
  }) {
    if (kDebugMode) {
      debugPrint('❌ [Analytics] Error in $method: $exception');
    }

    FirebaseCrashlyticsService.instance.recordError(
      exception: exception,
      stackTrace: stackTrace,
      reason: 'Analytics error in $method${additionalInfo != null ? ': $additionalInfo' : ''}',
      fatal: false,
    );
  }

  /// Reset analytics data (useful for testing or logout).
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
      if (kDebugMode) {
        debugPrint('🔄 [Analytics] Analytics data reset');
      }
    } catch (e, stack) {
      _handleError('resetAnalyticsData', e, stack);
    }
  }
}

// ============= Extension for Quick Access =============
extension AnalyticsExtension on AnalyticsService {
  /// Quick screen tracking
  Future<void> trackScreen(String name) => setCurrentScreen(screenName: name);

  /// Quick event tracking
  Future<void> trackEvent(String name, [Map<String, Object>? params]) =>
      logEvent(name: name, parameters: params);
}

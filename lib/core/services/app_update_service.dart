import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service for handling in-app updates
/// Forces users to update when a new version is available
class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._internal();
  factory AppUpdateService() => instance;
  AppUpdateService._internal();

  /// Check for app updates and force update if available
  /// This should be called on app startup
  Future<void> checkForUpdate({bool forceUpdate = true}) async {
    // Only check on Android (iOS handles updates differently)
    if (!Platform.isAndroid) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: Update check skipped (not Android)');
      }
      return;
    }

    try {
      // Check if update is available
      final updateInfo = await InAppUpdate.checkForUpdate();
      
      if (kDebugMode) {
        debugPrint('AppUpdateService: Update available: ${updateInfo.updateAvailability}');
        debugPrint('AppUpdateService: Immediate update allowed: ${updateInfo.immediateUpdateAllowed}');
        debugPrint('AppUpdateService: Flexible update allowed: ${updateInfo.flexibleUpdateAllowed}');
      }

      // If update is available
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (forceUpdate) {
          // Force immediate update (user cannot skip)
          if (updateInfo.immediateUpdateAllowed) {
            await _performImmediateUpdate();
          } else if (updateInfo.flexibleUpdateAllowed) {
            // If immediate update not allowed, try flexible update
            await _performFlexibleUpdate();
          } else {
            if (kDebugMode) {
              debugPrint('AppUpdateService: No update method available');
            }
          }
        } else {
          // Optional update (user can skip)
          if (updateInfo.flexibleUpdateAllowed) {
            await _performFlexibleUpdate();
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('AppUpdateService: No update available');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: Error checking for update: $e');
        debugPrint('AppUpdateService: Stack trace: $stackTrace');
      }
      // Don't block app startup if update check fails
    }
  }

  /// Perform immediate update (user cannot skip)
  /// This will show Google Play's update dialog automatically
  Future<void> _performImmediateUpdate() async {
    try {
      // This will automatically show Google Play's update dialog
      // User cannot skip this update - it's forced
      final result = await InAppUpdate.performImmediateUpdate();
      
      if (kDebugMode) {
        debugPrint('AppUpdateService: Immediate update result: ${result.toString()}');
      }

      // If immediate update failed, try flexible update as fallback
      if (result == AppUpdateResult.inAppUpdateFailed) {
        if (kDebugMode) {
          debugPrint('AppUpdateService: Immediate update failed, trying flexible update');
        }
        await _performFlexibleUpdate();
      }
      // If result is AppUpdateResult.success, the update dialog is shown
      // and the app will be updated automatically
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: Error performing immediate update: $e');
      }
    }
  }

  /// Perform flexible update (user can continue using app while downloading)
  Future<void> _performFlexibleUpdate() async {
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      
      if (kDebugMode) {
        debugPrint('AppUpdateService: Flexible update started: ${result.toString()}');
      }

      if (result == AppUpdateResult.success) {
        // Wait for update to complete, then restart
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: Error performing flexible update: $e');
      }
    }
  }

  /// Check for update and show dialog if available (optional update)
  Future<void> checkForUpdateWithDialog(BuildContext context) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Show dialog to user
        if (context.mounted) {
          _showUpdateDialog(context, updateInfo);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: Error checking for update with dialog: $e');
      }
    }
  }

  /// Show update dialog to user
  void _showUpdateDialog(BuildContext context, AppUpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('update.available_title'.tr()),
        content: Text('update.available_message'.tr()),
        actions: [
          if (updateInfo.flexibleUpdateAllowed)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performFlexibleUpdate();
              },
              child: Text('update.update_later'.tr()),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (updateInfo.immediateUpdateAllowed) {
                _performImmediateUpdate();
              } else if (updateInfo.flexibleUpdateAllowed) {
                _performFlexibleUpdate();
              }
            },
            child: Text('update.update_now'.tr()),
          ),
        ],
      ),
    );
  }
}


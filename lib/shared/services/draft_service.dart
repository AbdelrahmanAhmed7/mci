import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for saving and loading form drafts
class DraftService {
  static const String _draftPrefix = 'draft_';
  static const String _draftTimestampPrefix = 'draft_timestamp_';
  
  static DraftService? _instance;
  static DraftService get instance => _instance ??= DraftService._();
  
  DraftService._();

  /// Save draft data for a specific screen
  Future<bool> saveDraft(String screenKey, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setString('$_draftPrefix$screenKey', jsonString);
      await prefs.setInt('$_draftTimestampPrefix$screenKey', timestamp);
      
      debugPrint('💾 Draft saved for $screenKey');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save draft: $e');
      return false;
    }
  }

  /// Load draft data for a specific screen
  Future<Map<String, dynamic>?> loadDraft(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_draftPrefix$screenKey');
      
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('📂 Draft loaded for $screenKey');
      return data;
    } catch (e) {
      debugPrint('❌ Failed to load draft: $e');
      return null;
    }
  }

  /// Get the timestamp when the draft was last saved
  Future<DateTime?> getDraftTimestamp(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('$_draftTimestampPrefix$screenKey');
      
      if (timestamp == null) {
        return null;
      }
      
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Check if a draft exists for a specific screen
  Future<bool> hasDraft(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_draftPrefix$screenKey');
    } catch (e) {
      return false;
    }
  }

  /// Clear draft data for a specific screen
  Future<bool> clearDraft(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_draftPrefix$screenKey');
      await prefs.remove('$_draftTimestampPrefix$screenKey');
      
      debugPrint('🗑️ Draft cleared for $screenKey');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to clear draft: $e');
      return false;
    }
  }

  /// Clear all drafts
  Future<bool> clearAllDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_draftPrefix) || key.startsWith(_draftTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
      
      debugPrint('🗑️ All drafts cleared');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to clear all drafts: $e');
      return false;
    }
  }
}

/// Mixin to add draft functionality to a StatefulWidget
mixin DraftMixin<T extends StatefulWidget> on State<T> {
  final DraftService _draftService = DraftService.instance;
  bool _hasPendingDraft = false;
  DateTime? _lastDraftTime;
  
  /// Override this to provide the screen key for draft storage
  String get draftScreenKey;
  
  /// Override this to convert form data to a map
  Map<String, dynamic> collectDraftData();
  
  /// Override this to restore form data from a map
  void restoreDraftData(Map<String, dynamic> data);
  
  bool get hasPendingDraft => _hasPendingDraft;
  DateTime? get lastDraftTime => _lastDraftTime;

  /// Check for existing draft on init
  Future<void> checkForDraft() async {
    final hasDraft = await _draftService.hasDraft(draftScreenKey);
    if (hasDraft) {
      _hasPendingDraft = true;
      _lastDraftTime = await _draftService.getDraftTimestamp(draftScreenKey);
      if (mounted) setState(() {});
    }
  }

  /// Save current form data as draft
  Future<void> saveDraft() async {
    final data = collectDraftData();
    final success = await _draftService.saveDraft(draftScreenKey, data);
    if (success && mounted) {
      _lastDraftTime = DateTime.now();
      setState(() {});
    }
  }

  /// Load and restore draft data
  Future<bool> loadAndRestoreDraft() async {
    final data = await _draftService.loadDraft(draftScreenKey);
    if (data != null) {
      restoreDraftData(data);
      _hasPendingDraft = false;
      if (mounted) setState(() {});
      return true;
    }
    return false;
  }

  /// Clear the draft
  Future<void> clearDraft() async {
    await _draftService.clearDraft(draftScreenKey);
    _hasPendingDraft = false;
    _lastDraftTime = null;
    if (mounted) setState(() {});
  }
}

/// Screen keys for drafts
class DraftKeys {
  static const String approvalRequest = 'approval_request';
  static const String refundRequest = 'refund_request';
  static const String addFamilyMember = 'add_family_member';
}

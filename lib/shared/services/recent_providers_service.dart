import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing recently used providers
class RecentProvidersService {
  static const String _recentProvidersKey = 'recent_providers';
  static const int _maxRecentProviders = 5;
  
  static RecentProvidersService? _instance;
  static RecentProvidersService get instance => _instance ??= RecentProvidersService._();
  
  RecentProvidersService._();

  /// Get list of recently used providers
  Future<List<RecentProvider>> getRecentProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentProvidersKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => RecentProvider.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to get recent providers: $e');
      return [];
    }
  }

  /// Add a provider to recent list
  Future<bool> addRecentProvider(RecentProvider provider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getRecentProviders();
      
      // Remove if already exists (to move to top)
      currentList.removeWhere((p) => p.id == provider.id);
      
      // Add to beginning
      currentList.insert(0, provider);
      
      // Trim to max size
      final trimmedList = currentList.take(_maxRecentProviders).toList();
      
      // Save
      final jsonString = jsonEncode(trimmedList.map((p) => p.toJson()).toList());
      await prefs.setString(_recentProvidersKey, jsonString);
      
      debugPrint('✅ Added recent provider: ${provider.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to add recent provider: $e');
      return false;
    }
  }

  /// Remove a provider from recent list
  Future<bool> removeRecentProvider(int providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getRecentProviders();
      
      currentList.removeWhere((p) => p.id == providerId);
      
      final jsonString = jsonEncode(currentList.map((p) => p.toJson()).toList());
      await prefs.setString(_recentProvidersKey, jsonString);
      
      return true;
    } catch (e) {
      debugPrint('❌ Failed to remove recent provider: $e');
      return false;
    }
  }

  /// Clear all recent providers
  Future<bool> clearRecentProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentProvidersKey);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to clear recent providers: $e');
      return false;
    }
  }
}

/// Model for a recent provider
class RecentProvider {
  final int id;
  final String name;
  final String? logoUrl;
  final DateTime lastUsed;

  RecentProvider({
    required this.id,
    required this.name,
    this.logoUrl,
    DateTime? lastUsed,
  }) : lastUsed = lastUsed ?? DateTime.now();

  factory RecentProvider.fromJson(Map<String, dynamic> json) {
    return RecentProvider(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      lastUsed: json['lastUsed'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUsed'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
    };
  }
}

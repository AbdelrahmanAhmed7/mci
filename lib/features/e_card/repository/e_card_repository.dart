import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mediconsult/core/constants/api_result.dart';
import 'package:mediconsult/core/error/app_error_handler.dart';
import 'package:mediconsult/core/error/app_failure.dart';
import 'package:mediconsult/core/network/api_error_handler.dart';
import 'package:mediconsult/features/e_card/data/e_card_cache_owner_resolver.dart';
import 'package:mediconsult/features/e_card/data/e_card_local_data_source.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';
import 'package:mediconsult/features/e_card/repository/e_card_cache_lookup.dart';
import 'package:mediconsult/features/e_card/service/e_card_api_service.dart';

class ECardRepository {
  final ECardApiService _apiService;
  final ECardLocalDataSource _localDataSource;
  final ECardCacheOwnerResolver _ownerResolver;
  final BaseCacheManager? _imageCacheManager;

  ECardRepository(
    this._apiService,
    this._localDataSource,
    this._ownerResolver, {
    BaseCacheManager? imageCacheManager,
  }) : _imageCacheManager = imageCacheManager;

  Future<ECardCacheLookup> readCache() async {
    final ownerKey = await _ownerResolver.resolveOwnerKey();
    if (ownerKey == null || ownerKey.isEmpty) {
      return const ECardCacheLookup(
        ownerKey: null,
        validEntry: null,
        hadExpiredEntry: false,
      );
    }

    final entry = await _localDataSource.read(ownerKey);
    if (entry == null) {
      return ECardCacheLookup(
        ownerKey: ownerKey,
        validEntry: null,
        hadExpiredEntry: false,
      );
    }

    if (entry.isValid()) {
      return ECardCacheLookup(
        ownerKey: ownerKey,
        validEntry: entry,
        hadExpiredEntry: false,
      );
    }

    await _localDataSource.delete(ownerKey);
    return ECardCacheLookup(
      ownerKey: ownerKey,
      validEntry: null,
      hadExpiredEntry: true,
    );
  }

  Future<ApiResult<ECardData>> fetchFreshECard(
    String lang, {
    String? ownerKey,
  }) async {
    final effectiveOwnerKey =
        ownerKey ?? await _ownerResolver.resolveOwnerKey();
    if (effectiveOwnerKey == null || effectiveOwnerKey.isEmpty) {
      return const ApiResult.failure('errors.session_expired');
    }

    try {
      final response = await _apiService.getECard(lang);
      final data = response.data;
      if (response.success && data != null && data.hasMeaningfulData) {
        await _localDataSource.save(effectiveOwnerKey, data);
        _warmImageCache(data);
        return ApiResult.success(data);
      }
      return ApiResult.failure(
        response.message.isNotEmpty ? response.message : 'e_card.no_data',
      );
    } catch (error) {
      if (error is DioException && error.error is AppFailure) {
        return ApiResult.failure(
          AppErrorHandler.messageFromFailure(error.error as AppFailure),
        );
      }
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  Future<void> clearCurrentUserCache() async {
    final ownerKey = await _ownerResolver.resolveOwnerKey();
    if (ownerKey == null || ownerKey.isEmpty) return;
    await _localDataSource.delete(ownerKey);
  }

  Future<void> clearAllCache() => _localDataSource.clearAll();

  void _warmImageCache(ECardData data) {
    for (final url in [data.memberPhoto, data.insuranceCompanyLogo]) {
      final trimmedUrl = url.trim();
      if (!_isValidHttpUrl(trimmedUrl)) continue;
      unawaited(_downloadImage(trimmedUrl));
    }
  }

  Future<void> _downloadImage(String url) async {
    try {
      await (_imageCacheManager ?? DefaultCacheManager()).downloadFile(url);
    } catch (_) {}
  }

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}

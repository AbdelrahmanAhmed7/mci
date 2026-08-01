import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/core/constants/api_result.dart';
import 'package:mediconsult/core/network/connectivity_service.dart';
import 'package:mediconsult/features/e_card/data/e_card_cache_entry.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';
import 'package:mediconsult/features/e_card/presentation/cubit/e_card_state.dart';
import 'package:mediconsult/features/e_card/presentation/e_card_arabic_text.dart';
import 'package:mediconsult/features/e_card/repository/e_card_cache_lookup.dart';
import 'package:mediconsult/features/e_card/repository/e_card_repository.dart';

class ECardCubit extends Cubit<ECardState> {
  final ECardRepository _repository;
  final ConnectivityService _connectivityService;

  bool _isLoading = false;
  bool _offlineNoticeEmitted = false;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _connectivityDebounce;

  ECardCubit(this._repository, {ConnectivityService? connectivityService})
    : _connectivityService =
          connectivityService ?? ConnectivityService.instance,
      super(const ECardInitial()) {
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> load({required String lang, bool forceRefresh = false}) async {
    if (_isLoading) return;

    final currentState = state;
    final previousData = _previousData(currentState);
    if (!forceRefresh && currentState is ECardLoaded) return;

    _isLoading = true;
    try {
      final cacheLookup = await _repository.readCache();
      if (isClosed) return;

      final validCache = cacheLookup.validEntry;
      final shouldShowCache = validCache != null && !forceRefresh;

      if (shouldShowCache) {
        _emitCachedData(validCache, isRefreshing: true);
      } else if (previousData != null) {
        _emitPreviousDataRefreshing(currentState, previousData);
      } else {
        emit(const ECardLoading());
      }

      await _fetchFreshAndEmit(
        lang: lang,
        cacheLookup: cacheLookup,
        fallbackEntry: validCache,
        previousData: previousData,
      );
    } catch (error) {
      if (!isClosed) {
        emit(ECardFailure(error.toString(), previousData: previousData));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _fetchFreshAndEmit({
    required String lang,
    required ECardCacheLookup cacheLookup,
    required ECardCacheEntry? fallbackEntry,
    required ECardData? previousData,
  }) async {
    final result = await _repository.fetchFreshECard(
      lang,
      ownerKey: cacheLookup.ownerKey,
    );
    if (isClosed) return;

    result.when(
      success: (data) {
        _offlineNoticeEmitted = false;
        emit(ECardLoaded(data));
      },
      failure: (message) {
        final validFallback = fallbackEntry;
        if (validFallback != null && validFallback.isValid()) {
          _emitCachedData(
            validFallback,
            isRefreshing: false,
            isOffline: true,
            noticeMessage: _nextOfflineNotice(),
          );
          return;
        }

        if (previousData != null) {
          emit(
            ECardLoaded(
              previousData,
              isRefreshing: false,
              isOffline: true,
              noticeMessage: _nextOfflineNotice(),
            ),
          );
          return;
        }

        emit(
          ECardFailure(
            cacheLookup.hadExpiredEntry
                ? ECardArabicText.expiredCacheRequiresInternet
                : message,
            cacheExpired: cacheLookup.hadExpiredEntry,
          ),
        );
      },
    );
  }

  void _emitCachedData(
    ECardCacheEntry entry, {
    required bool isRefreshing,
    bool isOffline = false,
    String? noticeMessage,
  }) {
    if (isClosed) return;
    emit(
      ECardLoaded(
        entry.data,
        isFromCache: true,
        isRefreshing: isRefreshing,
        isOffline: isOffline,
        cachedAtUtc: entry.cachedAtUtc,
        noticeMessage: noticeMessage,
      ),
    );
  }

  void _emitPreviousDataRefreshing(ECardState state, ECardData previousData) {
    if (state is ECardLoaded) {
      emit(
        ECardLoaded(
          previousData,
          isFromCache: state.isFromCache,
          isRefreshing: true,
          isOffline: state.isOffline,
          cachedAtUtc: state.cachedAtUtc,
        ),
      );
      return;
    }
    emit(ECardLoading(previousData: previousData, isRefreshing: true));
  }

  String? _nextOfflineNotice() {
    if (_offlineNoticeEmitted) return null;
    _offlineNoticeEmitted = true;
    return ECardArabicText.cachedCopyInUse;
  }

  void _onConnectivityChanged(bool isOnline) {
    if (!isOnline || isClosed || _isLoading) return;
    final currentState = state;
    if (currentState is! ECardLoaded || !currentState.isFromCache) return;

    _connectivityDebounce?.cancel();
    _connectivityDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!isClosed) {
        load(lang: 'ar', forceRefresh: true);
      }
    });
  }

  ECardData? _previousData(ECardState state) {
    return switch (state) {
      ECardLoaded(:final data) => data,
      ECardLoading(:final previousData) => previousData,
      ECardFailure(:final previousData) => previousData,
      _ => null,
    };
  }

  @override
  Future<void> close() {
    _connectivityDebounce?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}

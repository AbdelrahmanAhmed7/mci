import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';

sealed class ECardState {
  const ECardState();
}

class ECardInitial extends ECardState {
  const ECardInitial();
}

class ECardLoading extends ECardState {
  final ECardData? previousData;
  final bool isRefreshing;

  const ECardLoading({this.previousData, this.isRefreshing = false});
}

class ECardLoaded extends ECardState {
  final ECardData data;
  final bool isFromCache;
  final bool isRefreshing;
  final bool isOffline;
  final DateTime? cachedAtUtc;
  final String? noticeMessage;

  const ECardLoaded(
    this.data, {
    this.isFromCache = false,
    this.isRefreshing = false,
    this.isOffline = false,
    this.cachedAtUtc,
    this.noticeMessage,
  });
}

class ECardFailure extends ECardState {
  final String message;
  final ECardData? previousData;
  final bool cacheExpired;

  const ECardFailure(
    this.message, {
    this.previousData,
    this.cacheExpired = false,
  });
}

import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';

class ECardCacheEntry {
  static const int currentVersion = 1;
  static const Duration validityDuration = Duration(days: 3);

  final ECardData data;
  final DateTime cachedAtUtc;
  final String ownerKey;
  final int version;

  const ECardCacheEntry({
    required this.data,
    required this.cachedAtUtc,
    required this.ownerKey,
    this.version = currentVersion,
  });

  bool isValid({DateTime? nowUtc}) {
    final now = (nowUtc ?? DateTime.now().toUtc()).toUtc();
    final cachedAt = cachedAtUtc.toUtc();
    if (cachedAt.isAfter(now)) return false;
    return now.difference(cachedAt) <= validityDuration;
  }

  factory ECardCacheEntry.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    if (dataJson is! Map<String, dynamic>) {
      throw const FormatException('Missing E-Card cache data');
    }

    final cachedAtText = json['cachedAtUtc']?.toString() ?? '';
    final cachedAt = DateTime.tryParse(cachedAtText);
    if (cachedAt == null) {
      throw const FormatException('Invalid E-Card cache timestamp');
    }

    return ECardCacheEntry(
      data: ECardData.fromJson(dataJson),
      cachedAtUtc: cachedAt.toUtc(),
      ownerKey: json['ownerKey']?.toString() ?? '',
      version: json['version'] is int ? json['version'] as int : currentVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.toJson(),
    'cachedAtUtc': cachedAtUtc.toUtc().toIso8601String(),
    'ownerKey': ownerKey,
    'version': version,
  };
}

import 'package:mediconsult/features/e_card/data/e_card_cache_entry.dart';

class ECardCacheLookup {
  final String? ownerKey;
  final ECardCacheEntry? validEntry;
  final bool hadExpiredEntry;

  const ECardCacheLookup({
    required this.ownerKey,
    required this.validEntry,
    required this.hadExpiredEntry,
  });

  bool get hasValidEntry => validEntry != null;
}

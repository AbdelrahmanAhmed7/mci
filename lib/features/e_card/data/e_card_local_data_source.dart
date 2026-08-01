import 'dart:convert';

import 'package:mediconsult/core/helpers/shared_pref_helper.dart';
import 'package:mediconsult/features/e_card/data/e_card_cache_entry.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';

abstract class ECardLocalDataSource {
  Future<ECardCacheEntry?> read(String ownerKey);
  Future<void> save(String ownerKey, ECardData data);
  Future<void> delete(String ownerKey);
  Future<void> clearAll();
}

class SecureECardLocalDataSource implements ECardLocalDataSource {
  static const String _keyPrefix = 'e_card_cache_v1_';
  static const String _knownOwnersKey = 'e_card_cache_known_owners_v1';

  @override
  Future<ECardCacheEntry?> read(String ownerKey) async {
    final cacheKey = _cacheKey(ownerKey);
    final raw = await SharedPrefHelper.getSecuredString(cacheKey);
    if (raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await delete(ownerKey);
        return null;
      }
      final entry = ECardCacheEntry.fromJson(decoded);
      if (entry.ownerKey != ownerKey || !entry.data.hasMeaningfulData) {
        await delete(ownerKey);
        return null;
      }
      return entry;
    } catch (_) {
      await delete(ownerKey);
      return null;
    }
  }

  @override
  Future<void> save(String ownerKey, ECardData data) async {
    if (!data.hasMeaningfulData) return;
    final entry = ECardCacheEntry(
      data: data,
      cachedAtUtc: DateTime.now().toUtc(),
      ownerKey: ownerKey,
    );
    await SharedPrefHelper.setSecuredString(
      _cacheKey(ownerKey),
      jsonEncode(entry.toJson()),
    );
    await _rememberOwner(ownerKey);
  }

  @override
  Future<void> delete(String ownerKey) async {
    await SharedPrefHelper.removeSecuredString(_cacheKey(ownerKey));
    await _forgetOwner(ownerKey);
  }

  @override
  Future<void> clearAll() async {
    final owners = await _knownOwners();
    for (final ownerKey in owners) {
      await SharedPrefHelper.removeSecuredString(_cacheKey(ownerKey));
    }
    await SharedPrefHelper.removeData(_knownOwnersKey);
  }

  String _cacheKey(String ownerKey) => '$_keyPrefix$ownerKey';

  Future<List<String>> _knownOwners() async {
    final raw = await SharedPrefHelper.getString(_knownOwnersKey);
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((value) => value.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> _rememberOwner(String ownerKey) async {
    final owners = {...await _knownOwners(), ownerKey}.toList();
    await SharedPrefHelper.setData(_knownOwnersKey, jsonEncode(owners));
  }

  Future<void> _forgetOwner(String ownerKey) async {
    final owners = (await _knownOwners())
        .where((knownOwner) => knownOwner != ownerKey)
        .toList();
    if (owners.isEmpty) {
      await SharedPrefHelper.removeData(_knownOwnersKey);
      return;
    }
    await SharedPrefHelper.setData(_knownOwnersKey, jsonEncode(owners));
  }
}

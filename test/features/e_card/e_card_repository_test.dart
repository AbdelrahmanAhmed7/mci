import 'package:flutter_test/flutter_test.dart';
import 'package:mediconsult/core/constants/api_result.dart';
import 'package:mediconsult/features/e_card/data/e_card_cache_entry.dart';
import 'package:mediconsult/features/e_card/data/e_card_cache_owner_resolver.dart';
import 'package:mediconsult/features/e_card/data/e_card_local_data_source.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';
import 'package:mediconsult/features/e_card/repository/e_card_repository.dart';
import 'package:mediconsult/features/e_card/service/e_card_api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockECardApiService extends Mock implements ECardApiService {}

class MockECardCacheOwnerResolver extends Mock
    implements ECardCacheOwnerResolver {}

class FakeECardLocalDataSource implements ECardLocalDataSource {
  final Map<String, ECardCacheEntry> entries = {};
  final List<String> deletedOwners = [];
  final List<String> savedOwners = [];

  @override
  Future<ECardCacheEntry?> read(String ownerKey) async => entries[ownerKey];

  @override
  Future<void> save(String ownerKey, ECardData data) async {
    savedOwners.add(ownerKey);
    entries[ownerKey] = ECardCacheEntry(
      data: data,
      cachedAtUtc: DateTime.now().toUtc(),
      ownerKey: ownerKey,
    );
  }

  @override
  Future<void> delete(String ownerKey) async {
    deletedOwners.add(ownerKey);
    entries.remove(ownerKey);
  }

  @override
  Future<void> clearAll() async => entries.clear();
}

void main() {
  late MockECardApiService api;
  late MockECardCacheOwnerResolver ownerResolver;
  late FakeECardLocalDataSource local;
  late ECardRepository repository;

  setUp(() {
    api = MockECardApiService();
    ownerResolver = MockECardCacheOwnerResolver();
    local = FakeECardLocalDataSource();
    repository = ECardRepository(api, local, ownerResolver);

    when(
      () => ownerResolver.resolveOwnerKey(),
    ).thenAnswer((_) async => 'member:1');
  });

  test(
    'readCache returns valid cache without extending its timestamp',
    () async {
      final cachedAt = DateTime.now().toUtc().subtract(
        const Duration(hours: 2),
      );
      local.entries['member:1'] = ECardCacheEntry(
        data: _eCardData(memberName: 'Cached'),
        cachedAtUtc: cachedAt,
        ownerKey: 'member:1',
      );

      final lookup = await repository.readCache();

      expect(lookup.validEntry?.data.memberName, 'Cached');
      expect(lookup.validEntry?.cachedAtUtc, cachedAt);
      expect(local.deletedOwners, isEmpty);
    },
  );

  test('readCache deletes expired cache and does not expose it', () async {
    local.entries['member:1'] = ECardCacheEntry(
      data: _eCardData(memberName: 'Expired'),
      cachedAtUtc: DateTime.now().toUtc().subtract(
        const Duration(days: 3, seconds: 1),
      ),
      ownerKey: 'member:1',
    );

    final lookup = await repository.readCache();

    expect(lookup.validEntry, isNull);
    expect(lookup.hadExpiredEntry, isTrue);
    expect(local.deletedOwners, ['member:1']);
  });

  test('fetchFreshECard saves meaningful API success', () async {
    final freshData = _eCardData(memberName: 'Fresh');
    when(() => api.getECard('ar')).thenAnswer(
      (_) async => ECardResponse(
        success: true,
        timestamp: 'now',
        message: 'ok',
        data: freshData,
      ),
    );

    final result = await repository.fetchFreshECard('ar');

    result.when(
      success: (data) => expect(data.memberName, 'Fresh'),
      failure: (_) => fail('expected success'),
    );
    expect(local.savedOwners, ['member:1']);
    expect(local.entries['member:1']?.data.memberName, 'Fresh');
  });

  test(
    'fetchFreshECard does not overwrite cache with invalid response',
    () async {
      final cachedData = _eCardData(memberName: 'Cached');
      local.entries['member:1'] = ECardCacheEntry(
        data: cachedData,
        cachedAtUtc: DateTime.now().toUtc(),
        ownerKey: 'member:1',
      );
      when(() => api.getECard('ar')).thenAnswer(
        (_) async => const ECardResponse(
          success: true,
          timestamp: 'now',
          message: 'empty',
          data: null,
        ),
      );

      final result = await repository.fetchFreshECard('ar');

      result.when(
        success: (_) => fail('expected failure'),
        failure: (message) => expect(message, 'empty'),
      );
      expect(local.entries['member:1']?.data.memberName, 'Cached');
    },
  );
}

ECardData _eCardData({required String memberName}) => ECardData(
  memberId: 1,
  memberCode: '911',
  memberName: memberName,
  memberPhoto: '',
  mciCard: '2088100',
  planTier: 'Bronze',
  planColor: '#CD7F32',
  policyExpireDate: '2028-12-31',
  insuranceCompanyName: 'Company',
  insuranceCompanyLogo: '',
  qrCodeValue: '',
  qrCodeImageUrl: '',
  coverageNotes: const ['note'],
);

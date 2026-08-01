import 'package:flutter_test/flutter_test.dart';
import 'package:mediconsult/features/e_card/data/e_card_cache_entry.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';

void main() {
  group('ECardCacheEntry', () {
    test('is valid exactly at the 72-hour boundary', () {
      final now = DateTime.utc(2026, 8, 1, 12);
      final entry = ECardCacheEntry(
        data: _eCardData(),
        cachedAtUtc: now.subtract(const Duration(days: 3)),
        ownerKey: 'member:1',
      );

      expect(entry.isValid(nowUtc: now), isTrue);
    });

    test('is expired after 72 hours', () {
      final now = DateTime.utc(2026, 8, 1, 12);
      final entry = ECardCacheEntry(
        data: _eCardData(),
        cachedAtUtc: now.subtract(const Duration(days: 3, microseconds: 1)),
        ownerKey: 'member:1',
      );

      expect(entry.isValid(nowUtc: now), isFalse);
    });

    test('future timestamps are invalid', () {
      final now = DateTime.utc(2026, 8, 1, 12);
      final entry = ECardCacheEntry(
        data: _eCardData(),
        cachedAtUtc: now.add(const Duration(minutes: 1)),
        ownerKey: 'member:1',
      );

      expect(entry.isValid(nowUtc: now), isFalse);
    });
  });
}

ECardData _eCardData() => const ECardData(
  memberId: 1,
  memberCode: '911',
  memberName: 'Member',
  memberPhoto: '',
  mciCard: '2088100',
  planTier: 'Bronze',
  planColor: '#CD7F32',
  policyExpireDate: '2028-12-31',
  insuranceCompanyName: 'Company',
  insuranceCompanyLogo: '',
  qrCodeValue: '',
  qrCodeImageUrl: '',
  coverageNotes: ['note'],
);

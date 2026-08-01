import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mediconsult/core/constants/constants.dart';
import 'package:mediconsult/core/helpers/shared_pref_helper.dart';

class ECardCacheOwnerResolver {
  const ECardCacheOwnerResolver();

  Future<String?> resolveOwnerKey() async {
    final memberId = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.memberId,
    );
    if (memberId.trim().isNotEmpty) {
      return 'member:${memberId.trim()}';
    }

    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    if (token.trim().isEmpty) return null;

    final digest = sha256.convert(utf8.encode(token.trim())).toString();
    return 'token:$digest';
  }
}

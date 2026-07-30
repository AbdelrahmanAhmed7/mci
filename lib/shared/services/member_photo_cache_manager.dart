import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/io_client.dart';

class MemberPhotoCacheManager extends CacheManager with ImageCacheManager {
  static const String key = 'memberPhotoCache';

  static final MemberPhotoCacheManager instance = MemberPhotoCacheManager._();

  MemberPhotoCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 100,
          fileService: HttpFileService(
            httpClient: IOClient(_createHttpClient()),
          ),
        ),
      );

  static HttpClient _createHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      return host == 'hcms.mediconsulteg.com';
    };
    return client;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/widgets/image_shimmer.dart';
import 'package:mediconsult/shared/services/member_photo_cache_manager.dart';

class MemberPhoto extends StatelessWidget {
  const MemberPhoto({
    super.key,
    required this.imageUrl,
    this.fallbackAsset = AppAssets.profile,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  });

  static const Map<String, String> _headers = {
    'Accept':
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
  };

  final String? imageUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  String? get _normalizedUrl {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return Uri.tryParse(url)?.toString() ?? url;
  }

  @override
  Widget build(BuildContext context) {
    final url = _normalizedUrl;
    if (url == null) {
      return Image.asset(fallbackAsset, fit: fit);
    }

    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: MemberPhotoCacheManager.instance,
      httpHeaders: _headers,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      cacheKey: url,
      placeholder: (context, url) => const ImageShimmer.circle(),
      errorWidget: (context, url, error) {
        if (kDebugMode) {
          debugPrint('MemberPhoto failed to load $url: $error');
        }
        return Image.asset(fallbackAsset, fit: fit);
      },
    );
  }
}

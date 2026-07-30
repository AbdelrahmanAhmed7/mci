import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/constants/app_assets.dart';

class ProviderLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final double borderRadius;
  final Color backgroundColor;

  const ProviderLogo({
    super.key,
    this.logoUrl,
    this.size = 56,
    this.borderRadius = 12,
    this.backgroundColor = AppColors.whiteClr,
  });

  bool get _hasValidLogo {
    return logoUrl != null && 
           logoUrl!.isNotEmpty && 
           logoUrl!.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: _hasValidLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius.r),
              child: CachedNetworkImage(
                imageUrl: logoUrl!,
                fit: BoxFit.cover,
                memCacheWidth: (size * 2).toInt(),
                memCacheHeight: (size * 2).toInt(),
                maxWidthDiskCache: (size * 2).toInt(),
                maxHeightDiskCache: (size * 2).toInt(),
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackLogo(),
              ),
            )
          : _buildFallbackLogo(),
    );
  }

  Widget _buildFallbackLogo() {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
    );
  }
}
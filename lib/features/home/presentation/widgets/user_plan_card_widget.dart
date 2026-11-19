import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/features/home/data/home_response_model.dart';
import 'package:mediconsult/shared/widgets/member_photo.dart';

class UserPlanCardWidget extends StatelessWidget {
  final HomeData data;
  final VoidCallback? onViewDigitalCard;

  const UserPlanCardWidget({
    super.key,
    required this.data,
    this.onViewDigitalCard,
  });

  String _initials() {
    final parts = data.memberName.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _planName(BuildContext context) {
    final name = data.programName.trim();
    if (name.isEmpty) return 'plan';
    if (name.toLowerCase().contains('platinum') || name.contains('بلاتينيوم')) {
      return context.locale.languageCode == 'ar' ? 'بلاتينيوم' : 'platinum';
    }
    if (name.toLowerCase().contains('gold') || name.contains('ذهبي')) {
      return context.locale.languageCode == 'ar' ? 'ذهبي' : 'gold';
    }
    return name;
  }

  String _formattedDate() {
    final raw = data.policyExpireDate;
    if (raw.isEmpty) return '--';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003B99), Color(0xFF0052D4)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -118.h,
            right: -97.w,
            child: Container(
              width: 256.w,
              height: 256.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .3),
                        ),
                      ),
                      child:
                          data.memberPhoto == null || data.memberPhoto!.isEmpty
                          ? Text(
                              _initials(),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : ClipOval(
                              child: MemberPhoto(
                                imageUrl: data.memberPhoto,
                                fallbackAsset: AppAssets.logo,
                                memCacheWidth: 96,
                                memCacheHeight: 96,
                                maxWidthDiskCache: 96,
                                maxHeightDiskCache: 96,
                              ),
                            ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 23.h,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  data.memberName.trim(),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    height: 20 / 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Primary · ${data.memberId}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                height: 16 / 12,
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _planName(context),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _InfoValue(label: 'MCI ID', value: '${data.memberId}'),
                    SizedBox(width: 32.w),
                    _InfoValue(label: 'VALID UNTIL', value: _formattedDate()),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(height: 1, color: Colors.white.withValues(alpha: .2)),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF34D399),
                    ),
                    SizedBox(width: 8.w),
                    const Expanded(
                      child: Text(
                        'Membership active',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 16 / 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onViewDigitalCard ?? () => context.push('/e-card'),
                      child: Row(
                        children: const [
                          Text(
                            'View digital card',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 16.w,
            top: 66.h,
            child: Container(
              width: 39.w,
              height: 37.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Image.asset(
                AppAssets.qrCode,
                width: 26.w,
                height: 26.w,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoValue extends StatelessWidget {
  final String label;
  final String value;

  const _InfoValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            height: 15 / 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

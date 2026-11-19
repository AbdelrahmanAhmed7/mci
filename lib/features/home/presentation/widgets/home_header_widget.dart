import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/services/notification_badge_service.dart';
import 'package:mediconsult/features/home/data/home_response_model.dart';
import 'package:mediconsult/shared/widgets/member_photo.dart';

class HomeHeaderWidget extends StatelessWidget {
  final HomeData data;

  const HomeHeaderWidget({super.key, required this.data});

  String _firstName() {
    final name = data.memberName.trim();
    return name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 107.h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning, 👋',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    _firstName(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5983F3),
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'Your health, our priority',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 16 / 12,
                          color: Color(0xFF2A9D8F),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.favorite_border,
                        size: 12,
                        color: Color(0xFF2A9D8F),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => context.push('/notifications'),
              borderRadius: BorderRadius.circular(24.r),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 21.w,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable:
                        NotificationBadgeService.instance.unreadCount,
                    builder: (context, count, _) {
                      final badge = count > 0 ? count : data.notificationsCount;
                      if (badge <= 0) return const SizedBox.shrink();
                      return Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              clipBehavior: Clip.antiAlias,
              child: MemberPhoto(
                imageUrl: data.memberPhoto,
                fallbackAsset: AppAssets.logo,
                memCacheWidth: 80,
                memCacheHeight: 80,
                maxWidthDiskCache: 80,
                maxHeightDiskCache: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

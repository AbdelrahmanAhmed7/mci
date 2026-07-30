import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/cache/cache_service.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/features/home/data/home_response_model.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_cubit.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_state.dart';
import 'package:mediconsult/features/profile/presentation/widgets/profile_header_shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/shared/widgets/member_photo.dart';

/// Profile header widget showing user info
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  Widget _buildFromCache() {
    return FutureBuilder<HomeResponse?>(
      future: CacheService.getCachedHomeData(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data;
        if (data == null) {
          return const ProfileHeaderShimmer();
        }
        return _buildHeader(context, data);
      },
    );
  }

  Widget _buildHeader(BuildContext context, HomeData data) {
    return Row(
      children: [
        Container(
          width: 74.w,
          height: 74.w,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: MemberPhoto(
            imageUrl: data.memberPhoto,
            fallbackAsset: AppAssets.profile,
            memCacheWidth: 148,
            memCacheHeight: 148,
            maxWidthDiskCache: 148,
            maxHeightDiskCache: 148,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.memberName,
                style: AppTextStyles.font14BlackMedium(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.font10GreyRegular(context),
                  children: [
                    TextSpan(text: 'profile.member_id'.tr()),
                    TextSpan(
                      text: data.memberId.toString(),
                      style: AppTextStyles.font12BlueRegular(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeCubitState>(
      builder: (context, state) {
        return state.when(
          initial: _buildFromCache,
          loading: _buildFromCache,
          loaded: (homeResponse) {
            final data = homeResponse.data;
            if (data == null) {
              return _buildFromCache();
            }
            return _buildHeader(context, data);
          },
          failed: (message) {
            return Row(
              children: [
                Container(
                  width: 74.w,
                  height: 74.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(AppAssets.profile, fit: BoxFit.cover),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.error_loading_profile'.tr(),
                        style: AppTextStyles.font14BlackMedium(context),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        message,
                        style: AppTextStyles.font10GreyRegular(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

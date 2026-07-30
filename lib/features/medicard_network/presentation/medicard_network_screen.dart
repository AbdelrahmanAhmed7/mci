import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/features/medicard_network/logic/medicard_network_cubit.dart';
import 'package:mediconsult/features/network/data/network_category_response_model.dart';
import 'package:mediconsult/features/network/data/network_provider_response_model.dart';
import 'package:mediconsult/features/network/data/government_response_model.dart';
import 'package:mediconsult/features/network/data/city_response_model.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class MedicardNetworkScreen extends StatefulWidget {
  const MedicardNetworkScreen({super.key});

  @override
  State<MedicardNetworkScreen> createState() => _MedicardNetworkScreenState();
}

class _MedicardNetworkScreenState extends State<MedicardNetworkScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const Color _medicardColor = Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    context.read<MedicardNetworkCubit>().loadInitialData('ar');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMaps(double latitude, double longitude, String? mapsUrl) async {
    if (latitude == 0 && longitude == 0) {
      return;
    }

    try {
      final Uri googleMapsAppUri = Uri.parse(
        'google.navigation:q=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleMapsAppUri)) {
        await launchUrl(googleMapsAppUri);
        return;
      }

      final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      if (await launchUrl(mapsUri, mode: LaunchMode.externalApplication)) {
        return;
      }

      if (mapsUrl != null && mapsUrl.isNotEmpty) {
        final Uri originalUri = Uri.parse(mapsUrl);
        await launchUrl(originalUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundClr,
      body: BlocBuilder<MedicardNetworkCubit, MedicardNetworkState>(
        builder: (context, state) {
          if (state is MedicardNetworkLoading) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySearchBarDelegate(
                    child: _buildSearchBar(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildShimmerLoading(),
                ),
              ],
            );
          }

          if (state is MedicardNetworkError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline, size: 50, color: Colors.red),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'حدث خطأ',
                      style: AppTextStyles.font20BlackSemiBold(context).copyWith(color: Colors.red),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font14GreyRegular(context),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => context.read<MedicardNetworkCubit>().loadInitialData('ar'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _medicardColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MedicardNetworkLoaded) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySearchBarDelegate(
                    child: _buildSearchBar(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _buildCategories(state.categories, state.selectedCategoryId),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFilters(state)),
                _buildProvidersListSliver(state),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      stretch: true,
      backgroundColor: _medicardColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'مقدمي الخدمة',
          style: AppTextStyles.font18BlackSemiBold(context).copyWith(color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _medicardColor,
                    _medicardColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -20.w,
              top: -20.h,
              child: Icon(
                Icons.local_hospital,
                size: 150.sp,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: AppColors.backgroundClr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (value) {
            context.read<MedicardNetworkCubit>().search(value.isEmpty ? null : value, 'ar');
          },
          style: AppTextStyles.font14BlackRegular(context),
          decoration: InputDecoration(
            hintText: 'ابحث عن عيادة، مستشفى أو صيدلية...',
            hintStyle: AppTextStyles.font14GreyRegular(context),
            prefixIcon: Icon(Icons.search, color: _medicardColor, size: 20.sp),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey, size: 18.sp),
                    onPressed: () {
                      _searchController.clear();
                      context.read<MedicardNetworkCubit>().search(null, 'ar');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(List<NetworkCategory> categories, int? selectedId) {
    if (categories.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'التصنيفات',
            style: AppTextStyles.font14BlackMedium(context),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 44.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip('الكل', null, selectedId == null);
              }
              final category = categories[index - 1];
              return _buildCategoryChip(category.name, category.id, selectedId == category.id);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, int? id, bool isSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: InkWell(
        onTap: () => context.read<MedicardNetworkCubit>().selectCategory(id, 'ar'),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? _medicardColor : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? _medicardColor : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _medicardColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              name,
              style: AppTextStyles.font12BlackMedium(context).copyWith(
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(MedicardNetworkLoaded state) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تخصيص البحث',
                style: AppTextStyles.font14BlackMedium(context),
              ),
              if (state.selectedGovernmentId != null || 
                  state.selectedCityId != null ||
                  state.selectedCategoryId != null)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<MedicardNetworkCubit>().clearFilters('ar');
                  },
                  child: Text(
                    'مسح الفلاتر',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'المحافظة',
                  state.governments,
                  state.selectedGovernmentId,
                  (id) => context.read<MedicardNetworkCubit>().selectGovernment(id, 'ar'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdown(
                  'المدينة',
                  state.cities,
                  state.selectedCityId,
                  (id) => context.read<MedicardNetworkCubit>().selectCity(id, 'ar'),
                  isCity: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    String hint,
    List<T> items,
    int? selectedId,
    Function(int?) onChanged, {
    bool isCity = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.grey.shade50,
      ),
      child: DropdownButton<int>(
        value: selectedId,
        hint: Text(hint, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: _medicardColor, size: 20.sp),
        dropdownColor: Colors.white,
        items: [
          DropdownMenuItem<int>(
            value: null,
            child: Text(
              hint,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ),
          ...items.map((item) {
            final id = item is Government ? item.id : (item as City).cityId;
            final name = item is Government ? item.name : (item as City).cityName;
            return DropdownMenuItem<int>(
              value: id,
              child: Text(
                name,
                style: TextStyle(fontSize: 12.sp),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProvidersListSliver(MedicardNetworkLoaded state) {
    if (state.providers.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded, size: 64, color: _medicardColor.withValues(alpha: 0.5)),
              ),
              SizedBox(height: 20.h),
              Text(
                'لا توجد نتائج بحث',
                style: AppTextStyles.font18BlackSemiBold(context),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'لم نجد مقدمي خدمة يطابقون بحثك الحالي، جرب تغيير الموقع أو كلمة البحث.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font14GreyRegular(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.providers.length) {
              context.read<MedicardNetworkCubit>().loadMore('ar');
              return Padding(
                padding: EdgeInsets.all(16.h),
                child: Center(
                  child: CircularProgressIndicator(color: _medicardColor, strokeWidth: 2),
                ),
              );
            }

            final provider = state.providers[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index % 5 * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _buildProviderCard(provider),
            );
          },
          childCount: state.providers.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(NetworkProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            // TODO: Navigate to provider details
          },
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: provider.providerLogo.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: provider.providerLogo,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Center(
                                  child: CircularProgressIndicator(
                                    color: _medicardColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Image.asset(
                                  AppAssets.logo,
                                  fit: BoxFit.contain,
                                  opacity: const AlwaysStoppedAnimation(0.5),
                                ),
                              )
                            : Image.asset(
                                AppAssets.logo,
                                fit: BoxFit.contain,
                                opacity: const AlwaysStoppedAnimation(0.5),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.providerName,
                        style: AppTextStyles.font16BlackMedium(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _medicardColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              provider.categoryName,
                              style: AppTextStyles.font10BlackMedium(context).copyWith(
                                color: _medicardColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (provider.distance != null)
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 12.sp, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  '${provider.distance!.toStringAsFixed(1)} كم',
                                  style: AppTextStyles.font10GreyRegular(context),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.map_outlined, size: 14.sp, color: Colors.grey),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              provider.area.isNotEmpty 
                                  ? '${provider.area} - ${provider.city}'
                                  : provider.fullAddress,
                              style: AppTextStyles.font12GreyRegular(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (provider.mobile.isNotEmpty)
                                  _buildActionButton(
                                    icon: Icons.phone_forwarded_rounded,
                                    label: provider.mobile,
                                    color: Colors.green,
                                    onTap: () => _makePhoneCall(provider.mobile),
                                  ),
                                if (provider.mobile.isNotEmpty && provider.hotline.isNotEmpty)
                                  SizedBox(width: 8.w),
                                if (provider.hotline.isNotEmpty)
                                  _buildActionButton(
                                    icon: Icons.headset_mic_rounded,
                                    label: provider.hotline,
                                    color: Colors.orange,
                                    onTap: () => _makePhoneCall(provider.hotline),
                                  ),
                              ],
                            ),
                            IconButton.filled(
                              onPressed: provider.mapsUrl.isNotEmpty
                                  ? () => _openMaps(provider.latitude, provider.longitude, provider.mapsUrl)
                                  : null,
                              icon: const Icon(Icons.directions_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: _medicardColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTextStyles.font10BlackMedium(context).copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundClr,
      child: child,
    );
  }

  @override
  double get maxExtent => 75.h;

  @override
  double get minExtent => 75.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

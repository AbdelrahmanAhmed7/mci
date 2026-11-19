import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/widgets/smooth_shimmer.dart';

class HomeLoadingWidget extends StatelessWidget {
  const HomeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Loading
          Container(
            height: 120.h,
            color: const Color(0xFFFAFBFF),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  SmoothShimmer(
                    baseColor: const Color(0xFFE5E7EB),
                    highlightColor: const Color(0xFFF3F4F6),
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SmoothShimmer(
                        baseColor: const Color(0xFFE5E7EB),
                        highlightColor: const Color(0xFFF3F4F6),
                        child: Container(
                          height: 16.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SmoothShimmer(
                        baseColor: const Color(0xFFE5E7EB),
                        highlightColor: const Color(0xFFF3F4F6),
                        child: Container(
                          height: 12.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Card Loading
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ShimmerCard(
              height: 100.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),

          // Content Loading
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: ShimmerCard(
                    height: 80.h,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

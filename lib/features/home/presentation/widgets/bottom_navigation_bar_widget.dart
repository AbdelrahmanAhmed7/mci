import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/services/haptic_feedback_service.dart';
import 'package:mediconsult/core/theming/app_colors.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  int _previousVisualIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousVisualIndex = _pageIndexToVisualIndex(widget.currentIndex);
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant BottomNavigationBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousVisualIndex = _pageIndexToVisualIndex(oldWidget.currentIndex);
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 32.w;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final selectedVisualIndex = _pageIndexToVisualIndex(widget.currentIndex);
    const visualItemCount = 5;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
      child: SizedBox(
        height: 80.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background bar
            Container(
              height: 65.h,
              decoration: BoxDecoration(
                color: AppColors.whiteClr,
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection: isRtl
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(visualItemCount, (index) {
                    return _NavItem(
                      index: index,
                      isSelected: selectedVisualIndex == index,
                      onTap: () {
                        HapticFeedbackService.instance.selectionClick();
                        widget.onTap(index);
                      },
                      label: _getLabel(index),
                      iconPath: _getIconPath(index, false),
                      iconData: _getIconData(index),
                    );
                  }),
                ),
              ),
            ),

            // Floating active indicator
            AnimatedBuilder(
              animation: _indicatorController,
              builder: (context, child) {
                final itemWidth = screenWidth / visualItemCount;
                final currentPos =
                    (selectedVisualIndex * itemWidth) + (itemWidth / 2) - 27.w;
                final previousPos =
                    (_previousVisualIndex * itemWidth) + (itemWidth / 2) - 27.w;

                final position = ui.lerpDouble(
                  previousPos,
                  currentPos,
                  Curves.easeOutCubic.transform(_indicatorController.value),
                )!;

                return Positioned(
                  top: -27.h,
                  left: isRtl ? null : position,
                  right: isRtl ? position : null,
                  child: child!,
                );
              },
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryClr.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: _BottomNavIcon(
                    iconPath: _getIconPath(selectedVisualIndex, true),
                    iconData: _getIconData(selectedVisualIndex),
                    color: AppColors.whiteClr,
                    size: 26.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'bottom_nav.home'.tr();
      case 1:
        return 'bottom_nav.provider'.tr();
      case 2:
        return 'bottom_nav.my_card'.tr();
      case 3:
        return 'bottom_nav.request'.tr();
      case 4:
        return 'bottom_nav.profile'.tr();
      default:
        return '';
    }
  }

  String? _getIconPath(int index, bool isActive) {
    switch (index) {
      case 0:
        return isActive ? AppAssets.homeActive : AppAssets.homeInactive;
      case 1:
        return isActive ? AppAssets.providerActive : AppAssets.providerInactive;
      case 2:
        return null;
      case 3:
        return isActive ? AppAssets.requestActive : AppAssets.requestInactive;
      case 4:
        return isActive ? AppAssets.profileActive : AppAssets.profileInactive;
      default:
        return '';
    }
  }

  IconData? _getIconData(int index) {
    switch (index) {
      case 2:
        return Icons.credit_card_outlined;
      default:
        return null;
    }
  }

  int _pageIndexToVisualIndex(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }
}

class _NavItem extends StatefulWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final String? iconPath;
  final IconData? iconData;

  const _NavItem({
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.iconPath,
    required this.iconData,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: SizedBox(
          width: 58.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isSelected ? 0.0 : 1.0,
                child: _BottomNavIcon(
                  iconPath: widget.iconPath,
                  iconData: widget.iconData,
                  color: AppColors.greyClr,
                  size: 22.w,
                ),
              ),
              SizedBox(height: 4.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: widget.isSelected
                      ? AppColors.primaryClr
                      : AppColors.greyClr,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.iconPath,
    required this.iconData,
    required this.color,
    required this.size,
  });

  final String? iconPath;
  final IconData? iconData;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconData != null) {
      return Icon(iconData, size: size, color: color);
    }

    final path = iconPath;
    if (path == null || path.isEmpty) {
      return SizedBox.square(dimension: size);
    }

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
    );
  }
}

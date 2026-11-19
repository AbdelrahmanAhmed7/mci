import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/services/haptic_feedback_service.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  int _visualIndex() {
    switch (currentIndex) {
      case 0:
        return 0;
      case 1:
        return 2;
      case 2:
        return 1;
      case 3:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _visualIndex();
    return SizedBox(
      height: 107.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 74.h,
              color: const Color(0xFFFAFBFF),
              padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  return _NavItem(
                    label: _labels[index],
                    iconPath: _icons[index],
                    iconData: index == 3 ? Icons.shield_outlined : null,
                    selected: selected == index,
                    onTap: () {
                      HapticFeedbackService.instance.selectionClick();
                      onTap(index);
                    },
                  );
                }),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left:
                16.w +
                selected * ((MediaQuery.sizeOf(context).width - 32.w) / 5) +
                ((MediaQuery.sizeOf(context).width - 32.w) / 10) -
                27.w,
            top: 4.h,
            child: Container(
              width: 54.w,
              height: 54.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _NavIcon(
                path: _icons[selected],
                iconData: selected == 3 ? Icons.shield_outlined : null,
                size: 26.w,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _labels = [
    'Home',
    'Approval',
    'Provider',
    'Benefits',
    'Profile',
  ];
  static const _icons = [
    AppAssets.homeInactive,
    AppAssets.requestInactive,
    AppAssets.providerInactive,
    '',
    AppAssets.profileInactive,
  ];
}

class _NavItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final IconData? iconData;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.iconPath,
    required this.iconData,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 24.h,
              child: selected
                  ? const SizedBox.shrink()
                  : _NavIcon(
                      path: iconPath,
                      iconData: iconData,
                      size: 22.w,
                      color: const Color(0xFF6B7280),
                    ),
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: selected
                    ? const Color(0xFF374151)
                    : const Color(0xFF6B7280),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String path;
  final IconData? iconData;
  final double size;
  final Color color;

  const _NavIcon({
    required this.path,
    required this.size,
    required this.color,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    if (iconData != null) {
      return Icon(iconData, size: size, color: color);
    }
    return Image.asset(path, width: size, height: size, color: color);
  }
}

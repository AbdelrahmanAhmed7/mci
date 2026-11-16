import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/font_manager.dart';

/// Single source of truth for Material defaults during the UI revamp.
/// Feature widgets can still opt into AppTextStyles while they migrate.
abstract final class AppTheme {
  static ThemeData light(BuildContext context) {
    final textTheme = ThemeData.light().textTheme.apply(
      fontFamily: FontManager.getFontFamily(context),
      bodyColor: AppColors.blackClr,
      displayColor: AppColors.blackClr,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundClr,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryClr,
        brightness: Brightness.light,
        surface: AppColors.whiteClr,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundClr,
        foregroundColor: AppColors.blackClr,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteClr,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderClr),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderClr),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primaryClr, width: 1.5),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.whiteClr,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.whiteClr,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

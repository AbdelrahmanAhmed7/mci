import 'package:material_ui/material_ui.dart';
import 'package:easy_localization/easy_localization.dart';

class FontManager {
  static String getFontFamily(BuildContext context) {
    final lang = context.locale.languageCode;
    return lang == 'ar' ? 'Cairo' : 'Inter';
  }
}

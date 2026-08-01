import 'package:flutter/material.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/features/e_card/presentation/e_card_arabic_text.dart';

class ECardErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ECardErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 720 || constraints.maxHeight < 330;
        final width = (constraints.maxWidth * 0.44).clamp(
          compact ? 260.0 : 320.0,
          compact ? 340.0 : 420.0,
        );
        return Center(
          child: Container(
            width: width,
            margin: const EdgeInsets.all(12),
            padding: EdgeInsets.all(compact ? 14 : 18),
            decoration: BoxDecoration(
              color: AppColors.whiteClr,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadowClr,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.credit_card_off_outlined,
                  color: AppColors.errorClr,
                  size: compact ? 32 : 38,
                ),
                SizedBox(height: compact ? 8 : 10),
                Text(
                  ECardArabicText.unableToLoad,
                  style: TextStyle(
                    color: AppColors.blackClr,
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: compact ? 5 : 7),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.greyClr,
                    fontSize: compact ? 10 : 11,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: compact ? 10 : 14),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text(ECardArabicText.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryClr,
                    foregroundColor: AppColors.whiteClr,
                    textStyle: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 18,
                      vertical: compact ? 8 : 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

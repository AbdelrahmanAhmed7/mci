import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/widgets/smooth_shimmer.dart';

class ECardLoadingWidget extends StatelessWidget {
  const ECardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dims = _LoadingDimensions.from(constraints);

        return Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              dims.screenPadding,
              2,
              dims.screenPadding,
              dims.screenPadding,
            ),
            child: SizedBox(
              width: dims.cardWidth,
              height: dims.cardHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.whiteClr,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadowClr,
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      Container(
                        height: dims.headerHeight,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(dims.contentPadding),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ShimmerCard(
                                    width: dims.photoWidth,
                                    height: dims.photoHeight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  SizedBox(width: dims.gap),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ShimmerCard(
                                          height: dims.lineHeight + 6,
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                        SizedBox(height: dims.gap),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ShimmerCard(
                                                height: dims.lineHeight,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                            SizedBox(width: dims.gap),
                                            Expanded(
                                              child: ShimmerCard(
                                                height: dims.lineHeight,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: dims.gap),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ShimmerCard(
                                                height: dims.lineHeight,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                            SizedBox(width: dims.gap),
                                            Expanded(
                                              child: ShimmerCard(
                                                height: dims.lineHeight,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: dims.gap),
                              Divider(height: 1, color: AppColors.borderClr),
                              SizedBox(height: dims.gap),
                              for (var index = 0; index < 3; index++) ...[
                                ShimmerCard(
                                  height: dims.noteHeight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                if (index != 2) SizedBox(height: dims.gap / 2),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingDimensions {
  final double cardWidth;
  final double cardHeight;
  final double screenPadding;
  final double contentPadding;
  final double headerHeight;
  final double photoWidth;
  final double photoHeight;
  final double gap;
  final double lineHeight;
  final double noteHeight;

  const _LoadingDimensions({
    required this.cardWidth,
    required this.cardHeight,
    required this.screenPadding,
    required this.contentPadding,
    required this.headerHeight,
    required this.photoWidth,
    required this.photoHeight,
    required this.gap,
    required this.lineHeight,
    required this.noteHeight,
  });

  factory _LoadingDimensions.from(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : 900.0;
    final maxHeight = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 330.0;
    final compact = maxWidth < 720 || maxHeight < 330;
    final screenPadding = (maxWidth * 0.018).clamp(8.0, 16.0);
    final availableWidth = math.max(280.0, maxWidth - (screenPadding * 2));
    final availableHeight = math.max(210.0, maxHeight - screenPadding - 2);
    final cardWidth = math.min(availableWidth, compact ? 860.0 : 980.0);
    final targetHeight = cardWidth / (compact ? 2.42 : 2.55);
    final minHeight = math.min(availableHeight, compact ? 224.0 : 260.0);
    final cardHeight = targetHeight
        .clamp(minHeight, availableHeight)
        .toDouble();
    final headerHeight = (cardHeight * 0.19).clamp(
      compact ? 42.0 : 50.0,
      compact ? 52.0 : 66.0,
    );
    final contentPadding = (cardWidth * 0.018).clamp(
      compact ? 9.0 : 12.0,
      compact ? 14.0 : 20.0,
    );
    final photoWidth = (cardWidth * (compact ? 0.118 : 0.125)).clamp(
      compact ? 62.0 : 82.0,
      compact ? 84.0 : 112.0,
    );

    return _LoadingDimensions(
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      screenPadding: screenPadding,
      contentPadding: contentPadding,
      headerHeight: headerHeight,
      photoWidth: photoWidth,
      photoHeight: photoWidth * 1.08,
      gap: (cardWidth * 0.014).clamp(6.0, 12.0),
      lineHeight: compact ? 15 : 18,
      noteHeight: compact ? 11 : 14,
    );
  }
}

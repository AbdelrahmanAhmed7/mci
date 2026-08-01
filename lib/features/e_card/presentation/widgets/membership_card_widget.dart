import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/widgets/image_shimmer.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';
import 'package:mediconsult/features/e_card/presentation/e_card_arabic_text.dart';

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({super.key, required this.data});

  final ECardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _ECardMetrics.fromConstraints(constraints);
        final notes = data.displayCoverageNotes;
        final planColor = _safePlanColor(data.planColor);

        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.outerPadding,
              vertical: 6,
            ),
            child: SizedBox(
              width: metrics.cardWidth,
              height: metrics.cardHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.whiteClr,
                  borderRadius: BorderRadius.circular(metrics.cardRadius),
                  border: Border.all(
                    color: AppColors.borderClr.withValues(alpha: 0.75),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadowClr,
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(metrics.cardRadius),
                  child: Column(
                    children: [
                      _MembershipCardHeader(data: data, metrics: metrics),
                      Expanded(
                        child: _MembershipCardBody(
                          data: data,
                          notes: notes,
                          planColor: planColor,
                          metrics: metrics,
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

class _ECardMetrics {
  const _ECardMetrics({
    required this.compact,
    required this.cardWidth,
    required this.cardHeight,
    required this.headerHeight,
    required this.outerPadding,
    required this.contentPadding,
    required this.cardRadius,
    required this.logoWidth,
    required this.logoHeight,
    required this.companyLogoSize,
    required this.photoWidth,
    required this.photoHeight,
    required this.sectionGap,
    required this.itemGap,
    required this.labelFontSize,
    required this.valueFontSize,
    required this.nameFontSize,
    required this.noteFontSize,
    required this.iconBoxSize,
  });

  final bool compact;
  final double cardWidth;
  final double cardHeight;
  final double headerHeight;
  final double outerPadding;
  final double contentPadding;
  final double cardRadius;
  final double logoWidth;
  final double logoHeight;
  final double companyLogoSize;
  final double photoWidth;
  final double photoHeight;
  final double sectionGap;
  final double itemGap;
  final double labelFontSize;
  final double valueFontSize;
  final double nameFontSize;
  final double noteFontSize;
  final double iconBoxSize;

  factory _ECardMetrics.fromConstraints(BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : 900.0;

    final availableHeight = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 360.0;

    final compact = availableWidth < 760 || availableHeight < 330;

    final outerPadding = (availableWidth * 0.025).clamp(10.0, 26.0);

    final usableWidth = math.max(280.0, availableWidth - (outerPadding * 2));

    final usableHeight = math.max(210.0, availableHeight - 8);

    final cardWidth = math.min(usableWidth, compact ? 930.0 : 1220.0);

    // Wide horizontal insurance-card ratio.
    final targetHeight = cardWidth / (compact ? 2.25 : 2.42);

    final cardHeight = math.min(
      usableHeight,
      math.max(compact ? 250.0 : 300.0, targetHeight),
    );

    final headerHeight = (cardHeight * 0.18).clamp(
      compact ? 46.0 : 54.0,
      compact ? 54.0 : 68.0,
    );

    final contentPadding = (cardWidth * 0.018).clamp(
      compact ? 10.0 : 14.0,
      compact ? 16.0 : 22.0,
    );

    final photoHeight = (cardHeight * 0.31).clamp(
      compact ? 82.0 : 100.0,
      compact ? 105.0 : 138.0,
    );

    return _ECardMetrics(
      compact: compact,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      headerHeight: headerHeight,
      outerPadding: outerPadding,
      contentPadding: contentPadding,
      cardRadius: compact ? 16 : 20,
      logoWidth: (cardWidth * 0.23).clamp(145.0, 245.0),
      logoHeight: (headerHeight * 0.64).clamp(30.0, 46.0),
      companyLogoSize: (headerHeight * 0.65).clamp(30.0, 44.0),
      photoWidth: photoHeight * 0.86,
      photoHeight: photoHeight,
      sectionGap: compact ? 8 : 12,
      itemGap: compact ? 6 : 10,
      labelFontSize: compact ? 9.5 : 11,
      valueFontSize: compact ? 12 : 14,
      nameFontSize: compact ? 15.5 : 19,
      noteFontSize: compact ? 10 : 11.5,
      iconBoxSize: compact ? 26 : 30,
    );
  }
}

class _MembershipCardHeader extends StatelessWidget {
  const _MembershipCardHeader({required this.data, required this.metrics});

  final ECardData data;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final companyName = data.insuranceCompanyName.trim();
    final companyLogo = data.insuranceCompanyLogo.trim();

    return Container(
      height: metrics.headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: metrics.contentPadding,
        vertical: 7,
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),

      // Keep the MCI logo on the left exactly like the reference,
      // while the company information stays on the right.
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Row(
          children: [
            SizedBox(
              width: metrics.logoWidth,
              height: metrics.logoHeight,
              child: Image.asset(
                AppAssets.logo,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                color: AppColors.whiteClr,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            const Spacer(),
            if (companyName.isNotEmpty || _isValidHttpUrl(companyLogo))
              Flexible(
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isValidHttpUrl(companyLogo)) ...[
                        CachedNetworkImage(
                          imageUrl: companyLogo,
                          imageBuilder: (context, provider) {
                            return Container(
                              width: metrics.companyLogoSize,
                              height: metrics.companyLogoSize,
                              decoration: BoxDecoration(
                                color: AppColors.whiteClr,
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: provider,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) => SizedBox.square(
                            dimension: metrics.companyLogoSize,
                            child: const ImageShimmer(
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (companyName.isNotEmpty)
                        Flexible(
                          child: Text(
                            companyName,
                            style: TextStyle(
                              color: AppColors.whiteClr,
                              fontSize: metrics.compact ? 11 : 13,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MembershipCardBody extends StatelessWidget {
  const _MembershipCardBody({
    required this.data,
    required this.notes,
    required this.planColor,
    required this.metrics,
  });

  final ECardData data;
  final List<String> notes;
  final Color planColor;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AppColors.whiteClr)),

        // Very subtle branded watermark.
        PositionedDirectional(
          start: metrics.contentPadding,
          top: 10,
          bottom: 10,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.025,
              child: SizedBox(
                width: metrics.cardWidth * 0.35,
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                  color: AppColors.primaryClr,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(metrics.contentPadding),
            child: Column(
              children: [
                Expanded(
                  flex: notes.isEmpty ? 1 : 3,
                  child: _MemberSection(
                    data: data,
                    planColor: planColor,
                    metrics: metrics,
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  SizedBox(height: metrics.sectionGap),
                  Divider(height: 1, color: AppColors.borderClr),
                  SizedBox(height: metrics.sectionGap),
                  Expanded(
                    flex: 2,
                    child: _CoverageNotesSection(
                      notes: notes,
                      metrics: metrics,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberSection extends StatelessWidget {
  const _MemberSection({
    required this.data,
    required this.planColor,
    required this.metrics,
  });

  final ECardData data;
  final Color planColor;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    // Force the photo to stay on the left like the supplied design.
    // The information itself remains Arabic RTL.
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _MemberPhoto(
            imageUrl: data.memberPhoto,
            width: metrics.photoWidth,
            height: metrics.photoHeight,
            metrics: metrics,
          ),
          SizedBox(width: metrics.compact ? 14 : 24),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: _MemberInformation(
                data: data,
                planColor: planColor,
                metrics: metrics,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberPhoto extends StatelessWidget {
  const _MemberPhoto({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.metrics,
  });

  final String imageUrl;
  final double width;
  final double height;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.splashScreenBackgroundClr,
        borderRadius: BorderRadius.circular(metrics.compact ? 13 : 16),
        border: Border.all(color: AppColors.borderClr),
      ),
      child: _isValidHttpUrl(url)
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, value) => const ImageShimmer(
                width: double.infinity,
                height: double.infinity,
              ),
              errorWidget: (context, value, error) =>
                  _MemberPhotoFallback(metrics: metrics),
            )
          : _MemberPhotoFallback(metrics: metrics),
    );
  }
}

class _MemberPhotoFallback extends StatelessWidget {
  const _MemberPhotoFallback({required this.metrics});

  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person,
        size: metrics.compact ? 40 : 54,
        color: AppColors.primaryClr.withValues(alpha: 0.55),
      ),
    );
  }
}

class _MemberInformation extends StatelessWidget {
  const _MemberInformation({
    required this.data,
    required this.planColor,
    required this.metrics,
  });

  final ECardData data;
  final Color planColor;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final expiryDate = _formatArabicPolicyDate(data.policyExpireDate);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoBlock(
          icon: Icons.person_outline,
          label: ECardArabicText.memberName,
          value: data.displayMemberName,
          metrics: metrics,
          isName: true,
        ),
        SizedBox(height: metrics.itemGap),
        _TwoColumnInformationRow(
          gap: metrics.itemGap,
          first: _InfoBlock(
            icon: Icons.badge_outlined,
            label: ECardArabicText.memberCode,
            value: data.memberCode.trim(),
            metrics: metrics,
          ),
          second: _InfoBlock(
            icon: Icons.credit_card_outlined,
            label: ECardArabicText.mciCardNumber,
            value: data.mciCard.trim(),
            metrics: metrics,
          ),
        ),
        SizedBox(height: metrics.itemGap),
        _TwoColumnInformationRow(
          gap: metrics.itemGap,
          first: _InfoBlock(
            icon: Icons.verified_user_outlined,
            label: ECardArabicText.planTier,
            value: data.planTier.trim(),
            metrics: metrics,
            accentColor: planColor,
            displayAsChip: true,
          ),
          second: _InfoBlock(
            icon: Icons.event_available_outlined,
            label: ECardArabicText.policyExpiryDate,
            value: expiryDate,
            metrics: metrics,
          ),
        ),
      ],
    );
  }
}

class _TwoColumnInformationRow extends StatelessWidget {
  const _TwoColumnInformationRow({
    required this.first,
    required this.second,
    required this.gap,
  });

  final Widget first;
  final Widget second;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: gap * 1.5),
        Expanded(child: second),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.metrics,
    this.accentColor,
    this.displayAsChip = false,
    this.isName = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final _ECardMetrics metrics;
  final Color? accentColor;
  final bool displayAsChip;
  final bool isName;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primaryClr;
    final displayValue = value.trim().isEmpty
        ? ECardArabicText.noData
        : value.trim();

    final valueDirection = _detectTextDirection(displayValue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: metrics.iconBoxSize,
          height: metrics.iconBoxSize,
          decoration: BoxDecoration(
            color: displayAsChip
                ? effectiveAccent.withValues(alpha: 0.1)
                : AppColors.splashScreenBackgroundClr,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: metrics.compact ? 14 : 17,
            color: displayAsChip ? effectiveAccent : AppColors.primaryClr,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.greyClr,
                  fontSize: metrics.labelFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 3),
              if (displayAsChip)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: metrics.compact ? 135 : 175,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.compact ? 8 : 12,
                      vertical: metrics.compact ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: effectiveAccent.withValues(alpha: 0.72),
                      ),
                    ),
                    child: Text(
                      displayValue,
                      style: TextStyle(
                        color: effectiveAccent,
                        fontSize: metrics.valueFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: valueDirection,
                    ),
                  ),
                )
              else
                Directionality(
                  textDirection: valueDirection,
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      color: AppColors.blackClr,
                      fontSize: isName
                          ? metrics.nameFontSize
                          : metrics.valueFontSize,
                      fontWeight: isName ? FontWeight.w800 : FontWeight.w700,
                      height: 1.15,
                    ),
                    maxLines: isName ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverageNotesSection extends StatelessWidget {
  const _CoverageNotesSection({required this.notes, required this.metrics});

  final List<String> notes;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.splashScreenBackgroundClr.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(metrics.compact ? 10 : 13),
        border: Border.all(color: AppColors.borderClr.withValues(alpha: 0.75)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.compact ? 9 : 13,
          vertical: metrics.compact ? 7 : 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ECardArabicText.coverageNotes,
              style: TextStyle(
                color: AppColors.primaryClr,
                fontSize: metrics.valueFontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: metrics.compact ? 5 : 7),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: notes.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return Divider(
                    height: metrics.compact ? 8 : 10,
                    color: AppColors.borderClr.withValues(alpha: 0.65),
                  );
                },
                itemBuilder: (context, index) {
                  return _CoverageNoteRow(note: notes[index], metrics: metrics);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageNoteRow extends StatelessWidget {
  const _CoverageNoteRow({required this.note, required this.metrics});

  final String note;
  final _ECardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.primaryClr,
            size: metrics.compact ? 14 : 16,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                color: AppColors.blackClr,
                fontSize: metrics.noteFontSize,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isValidHttpUrl(String value) {
  final uri = Uri.tryParse(value.trim());

  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

Color _safePlanColor(String value) {
  final parsedColor = _parseHexColor(value);

  if (parsedColor == null) {
    return AppColors.primaryClr;
  }

  final luminance = parsedColor.computeLuminance();

  if (luminance < 0.08 || luminance > 0.88) {
    return AppColors.primaryClr;
  }

  return parsedColor;
}

Color? _parseHexColor(String value) {
  var hex = value.trim();

  if (hex.isEmpty) return null;

  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }

  if (hex.length == 6) {
    hex = 'FF$hex';
  }

  if (hex.length != 8) {
    return null;
  }

  final parsed = int.tryParse(hex, radix: 16);

  if (parsed == null) {
    return null;
  }

  return Color(parsed);
}

String _formatArabicPolicyDate(String value) {
  final trimmedValue = value.trim();

  if (trimmedValue.isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(trimmedValue);

  if (parsedDate == null) {
    return '';
  }

  try {
    return DateFormat('d MMMM yyyy', 'ar').format(parsedDate);
  } catch (_) {
    return '';
  }
}

ui.TextDirection _detectTextDirection(String value) {
  final match = RegExp(r'[\u0600-\u06FFA-Za-z]').firstMatch(value.trim());

  final firstCharacter = match?.group(0);

  if (firstCharacter == null) {
    return ui.TextDirection.rtl;
  }

  return RegExp(r'[A-Za-z]').hasMatch(firstCharacter)
      ? ui.TextDirection.ltr
      : ui.TextDirection.rtl;
}

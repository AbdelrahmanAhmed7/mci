import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/features/e_card/presentation/e_card_arabic_text.dart';
import 'package:mediconsult/features/e_card/presentation/cubit/e_card_cubit.dart';
import 'package:mediconsult/features/e_card/presentation/cubit/e_card_state.dart';
import 'package:mediconsult/features/e_card/presentation/widgets/e_card_error_widget.dart';
import 'package:mediconsult/features/e_card/presentation/widgets/e_card_loading_widget.dart';
import 'package:mediconsult/features/e_card/presentation/widgets/membership_card_widget.dart';

class ECardScreen extends StatefulWidget {
  const ECardScreen({super.key});

  @override
  State<ECardScreen> createState() => _ECardScreenState();
}

class _ECardScreenState extends State<ECardScreen> with WidgetsBindingObserver {
  static const MethodChannel _orientationChannel = MethodChannel(
    'mediconsult/orientation',
  );

  bool _isClosing = false;
  bool _allowPop = false;
  Completer<void>? _portraitMetricsCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_setLandscapeOrientation());
  }

  @override
  void didChangeMetrics() {
    if (_portraitMetricsCompleter == null) return;
    if (_isPortraitMetrics()) {
      _completePortraitMetricsWaiter();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _completePortraitMetricsWaiter();
    unawaited(_setPortraitOrientation());
    super.dispose();
  }

  Future<void> _setLandscapeOrientation() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _setNativeOrientation('landscape');
      return;
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _setPortraitOrientation() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _setNativeOrientation('portrait');
      return;
    }

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _closeECard() async {
    if (_isClosing) return;
    _isClosing = true;
    if (mounted) {
      setState(() {});
    }

    await _setPortraitOrientation();
    await _waitForPortraitMetrics();

    if (!mounted) return;
    setState(() {
      _allowPop = true;
    });
    await _waitForNextFrame();

    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    }
  }

  Future<void> _waitForPortraitMetrics() async {
    if (_isPortraitMetrics()) return;

    final completer = Completer<void>();
    _portraitMetricsCompleter = completer;
    await completer.future.timeout(
      const Duration(milliseconds: 700),
      onTimeout: () {},
    );
    if (identical(_portraitMetricsCompleter, completer)) {
      _portraitMetricsCompleter = null;
    }
  }

  void _completePortraitMetricsWaiter() {
    final completer = _portraitMetricsCompleter;
    _portraitMetricsCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  bool _isPortraitMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    if (view == null) return true;

    final logicalSize = view.physicalSize / view.devicePixelRatio;
    if (logicalSize.width == 0 || logicalSize.height == 0) return true;
    return logicalSize.width < logicalSize.height;
  }

  Future<void> _waitForNextFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future.timeout(
      const Duration(milliseconds: 100),
      onTimeout: () {},
    );
  }

  Future<void> _setNativeOrientation(String orientation) async {
    try {
      await _orientationChannel.invokeMethod<void>(orientation);
    } on MissingPluginException {
      // Android and other platforms rely on SystemChrome only.
    }
  }

  @override
  Widget build(BuildContext context) {
    final transitionColor = Theme.of(context).scaffoldBackgroundColor;
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_closeECard());
      },
      child: Scaffold(
        backgroundColor: transitionColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              if (_isClosing || !isLandscape) {
                return _StableTransitionBackground(color: transitionColor);
              }

              return Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    _ECardTopBar(
                      onBack: _closeECard,
                      maxWidth: constraints.maxWidth,
                    ),
                    const Expanded(child: _ECardBody()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ECardTopBar extends StatelessWidget {
  const _ECardTopBar({required this.onBack, required this.maxWidth});

  final VoidCallback onBack;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = (maxWidth * 0.02).clamp(10.0, 18.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 2),
      child: SizedBox(
        height: 42,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.whiteClr,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadowClr,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox.square(
                dimension: 36,
                child: BackButton(onPressed: onBack, color: AppColors.blackClr),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ECardArabicText.title,
                style: AppTextStyles.font14BlackMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w700, height: 1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ECardBody extends StatelessWidget {
  const _ECardBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ECardCubit, ECardState>(
      listenWhen: (previous, current) {
        if (current is ECardFailure && current.previousData != null) {
          return true;
        }
        if (current is ECardLoaded &&
            current.noticeMessage != null &&
            current.noticeMessage!.isNotEmpty) {
          return previous is! ECardLoaded ||
              previous.noticeMessage != current.noticeMessage;
        }
        return false;
      },
      listener: (context, state) {
        final message = switch (state) {
          ECardLoaded(:final noticeMessage) => noticeMessage,
          ECardFailure() => ECardArabicText.unableToLoad,
          _ => null,
        };
        if (message == null || message.isEmpty) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: state is ECardLoaded
                ? AppColors.primaryClr
                : AppColors.errorClr,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      builder: (context, state) {
        return switch (state) {
          ECardLoaded(:final data) => MembershipCardWidget(data: data),
          ECardFailure(:final previousData) when previousData != null =>
            MembershipCardWidget(data: previousData),
          ECardFailure(:final message) => ECardErrorWidget(
            message: message.isEmpty ? ECardArabicText.unableToLoad : message,
            onRetry: () {
              context.read<ECardCubit>().load(lang: 'ar', forceRefresh: true);
            },
          ),
          ECardLoading(:final previousData) when previousData != null =>
            MembershipCardWidget(data: previousData),
          _ => const ECardLoadingWidget(),
        };
      },
    );
  }
}

class _StableTransitionBackground extends StatelessWidget {
  final Color color;

  const _StableTransitionBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          onEnd: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.whiteClr,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadowClr,
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                  color: AppColors.primaryClr,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 14),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: AppColors.primaryClr,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

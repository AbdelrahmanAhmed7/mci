import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/features/onboarding/onboarding_model';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final int pageIndex;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  const OnboardingPage({
    super.key,
    required this.model,
    required this.pageIndex,
    required this.pageCount,
    required this.onNext,
    required this.onSkip,
    this.onBack,
  });

  static const _blue = Color(0xff5983f3);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: model.isWelcome
                ? const Color(0xffdae0ff)
                : const Color(0xfffafbff),
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: ColoredBox(
            color: const Color(0xfffafbff),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 430,
                  height: 932,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      if (model.isWelcome) _welcomeBackground(),
                      Positioned(
                        top: 4,
                        left: 100,
                        width: 230,
                        height: 230,
                        child: Image.asset(model.topImage, fit: BoxFit.contain),
                      ),
                      _hero(),
                      model.isWelcome ? _welcomeCopy() : _content(),
                      if (!model.isWelcome && onBack != null) _backButton(),
                      _progress(),
                      _actions(),
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

  Widget _welcomeBackground() {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.5, 0.87],
            colors: [Colors.white, Color(0xffdae0ff)],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    if (model.isWelcome) {
      return Positioned(
        left: 0,
        top: 380,
        width: 430,
        height: 287,
        child: Image.asset(model.heroImage, fit: BoxFit.contain),
      );
    }

    return Positioned(
      left: model.heroLeft,
      top: 199,
      width: model.heroWidth,
      height: 293,
      child: Image.asset(model.heroImage, fit: BoxFit.contain),
    );
  }

  Widget _welcomeCopy() {
    return Positioned(
      left: 38,
      right: 38,
      top: 199,
      child: Column(
        children: [
          Text(
            tr(model.title),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Text(
            tr(model.description),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xff6b7280),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Positioned(
      left: 67,
      right: 67,
      top: 540,
      child: Column(
        children: [
          Text(
            tr(model.title),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            tr(model.description),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xff6b7280),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Positioned(
      left: 16,
      top: 88,
      child: GestureDetector(
        onTap: onBack,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: 60,
          height: 52,
          child: Align(
            alignment: Alignment(0.33, 0),
            child: Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _progress() {
    return Positioned(
      top: 712,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount * 2 - 1, (index) {
          if (index.isOdd) return const SizedBox(width: 3);
          final active = index ~/ 2 == pageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: active ? 19 : 10,
            height: 7,
            decoration: BoxDecoration(
              color: active ? _blue : const Color(0xffb4b4b4),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  Widget _actions() {
    return Positioned(
      left: 18,
      top: 766,
      width: 396,
      child: Column(
        children: [
          SizedBox(
            width: 396,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                tr('common.next'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(
              tr('common.skip'),
              style: const TextStyle(fontSize: 16, color: _blue),
            ),
          ),
        ],
      ),
    );
  }
}

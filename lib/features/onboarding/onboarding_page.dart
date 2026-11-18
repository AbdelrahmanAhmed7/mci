import 'package:easy_localization/easy_localization.dart';
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
        final scale = (constraints.maxWidth / 430)
            .clamp(0.75, constraints.maxHeight / 932)
            .toDouble();
        return ColoredBox(
          color: const Color(0xfffafbff),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 430,
                height: 932,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (model.isWelcome) _welcomeBackground(),
                    _statusBar(),
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
                    _homeIndicator(),
                  ],
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

  Widget _statusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 58,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 18, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '9:41',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Row(
              children: const [
                Icon(Icons.signal_cellular_alt, size: 14),
                SizedBox(width: 4),
                Icon(Icons.wifi, size: 14),
                SizedBox(width: 4),
                Icon(Icons.battery_full, size: 16),
              ],
            ),
          ],
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

    if (model.cropHero) {
      return Positioned(
        left: 65,
        top: 199,
        width: 300,
        height: 293,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: 2282,
            child: Image.asset(
              model.heroImage,
              width: 2282,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    return Positioned(
      left: -9,
      top: 199,
      width: 439,
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
      top: 452,
      child: GestureDetector(
        onTap: onBack,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back, size: 22),
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
        children: List.generate(pageCount, (index) {
          final active = index == pageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
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
      left: 17,
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

  Widget _homeIndicator() {
    return Positioned(
      left: 143,
      bottom: 0,
      width: 144,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xe5060e16),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

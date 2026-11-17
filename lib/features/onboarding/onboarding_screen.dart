import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/constants/constants.dart';
import 'package:mediconsult/core/helpers/shared_pref_helper.dart';
import 'package:mediconsult/features/onboarding/onboarding_model';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      topImage: 'assets/onboarding/figma/welcome_top.png',
      heroImage: '',
      title: 'onboarding.welcome_title',
      description: 'onboarding.welcome_description',
      isWelcome: true,
    ),
    OnboardingModel(
      topImage: 'assets/onboarding/figma/page1_top.png',
      heroImage: 'assets/onboarding/figma/page1_hero.png',
      title: 'onboarding.request_approvals',
      description: 'onboarding.request_approvals_description',
    ),
    OnboardingModel(
      topImage: 'assets/onboarding/figma/page2_top.png',
      heroImage: 'assets/onboarding/figma/page2_hero.png',
      title: 'onboarding.digital_card',
      description: 'onboarding.digital_card_description',
    ),
    OnboardingModel(
      topImage: 'assets/onboarding/figma/page3_top.png',
      heroImage: 'assets/onboarding/figma/page3_hero.png',
      title: 'onboarding.help',
      description: 'onboarding.help_description',
      cropHero: true,
    ),
  ];

  Future<void> _finish() async {
    await SharedPrefHelper.setData(SharedPrefKeys.hasSeenOnboarding, true);
    shouldShowOnboarding = false;
    if (!mounted) return;
    context.go(isLoggedInUser ? '/home' : '/login');
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) => OnboardingPage(
          model: _pages[index],
          pageIndex: index,
          pageCount: _pages.length,
          onNext: _next,
          onSkip: _finish,
          onBack: index == 0
              ? null
              : () => _controller.previousPage(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                ),
        ),
      ),
    );
  }
}

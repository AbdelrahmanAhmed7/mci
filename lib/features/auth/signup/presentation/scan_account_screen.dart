import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/theming/figma_colors.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';

class ScanAccountScreen extends StatelessWidget {
  const ScanAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => FigmaAccountPage(
    step: 'Step 1/4',
    onBack: () => context.pop(),
    child: Stack(
      children: [
        const FigmaProgress(activeStep: 1),
        const Positioned(
          left: 21,
          top: 186,
          width: 388,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan your Digital Card',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.neutral900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Camera access is needed only to capture your Card. Images are processed and never shared.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  height: 1.45,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 21,
          top: 288,
          child: Container(
            width: 388,
            height: 253,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                width: 310,
                height: 156,
                decoration: BoxDecoration(
                  border: Border.all(color: FigmaColors.blue500, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.credit_card_outlined,
                    size: 40,
                    color: FigmaColors.blue500,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 541,
          child: Column(
            children: [
              FigmaAuthButton(text: 'Allow Camera & Capture', onPressed: () {}),
              const SizedBox(height: 16),
              SizedBox(
                width: 397,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.push('/signup/manual'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: FigmaColors.blue500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enter Manually',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: FigmaColors.blue500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

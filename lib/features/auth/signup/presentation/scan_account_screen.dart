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
        const FigmaProgress(activeStep: 2),
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
          top: 317,
          child: Container(
            width: 388,
            height: 194,
            decoration: BoxDecoration(
              color: const Color(0xFF121E38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                width: 310,
                height: 156,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF31578D), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: Color(0xFF5576A7),
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
                height: 24,
                child: Center(
                  child: FigmaAuthBackLink(
                    text: 'Enter Manually',
                    onPressed: () => context.push('/signup/manual'),
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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/figma_colors.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaAccountPage(
      step: 'Step 1/4',
      onBack: () => context.go('/login'),
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
                  'How would you like to register?',
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
                  'Scanning your Digital Card is faster and reduces typing errors.',
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
            top: 302,
            child: FigmaAccountCard(
              title: 'Scan National ID',
              description: 'We extract your details, you review them.',
              iconAsset: AppAssets.accountScanMethod,
              recommended: true,
              onTap: () => context.push('/signup/scan'),
            ),
          ),
          Positioned(
            left: 21,
            // First card ends at 395, leaving a 20 px gap.
            top: 408,
            child: FigmaAccountCard(
              title: 'Enter details manually',
              description: 'Takes about 2 minutes',
              iconAsset: AppAssets.accountManualMethod,
              onTap: () => context.push('/signup/manual'),
            ),
          ),
        ],
      ),
    );
  }
}

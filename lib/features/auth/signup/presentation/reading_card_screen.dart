import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';

class ReadingCardScreen extends StatelessWidget {
  final String imagePath;

  const ReadingCardScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) => FigmaAccountPage(
    step: 'Step 2/4',
    onBack: () => context.pop(),
    child: Stack(
      children: [
        const Positioned(
          left: 21,
          top: 186,
          width: 388,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reading your card',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We are reading the captured image. This usually takes a few seconds.',
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
            height: 240,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF121E38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
        ),
        const Positioned(
          left: 21,
          top: 581,
          width: 388,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1769E0),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Processing card image...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          top: 650,
          child: FigmaAuthBackLink(
            text: 'Retake photo',
            onPressed: () => context.pop(),
          ),
        ),
      ],
    ),
  );
}

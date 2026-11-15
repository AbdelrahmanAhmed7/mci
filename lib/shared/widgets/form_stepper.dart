import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';

/// A horizontal stepper widget showing form progress
class FormStepper extends StatelessWidget {
  final List<FormStep> steps;
  final int currentStep;
  final bool showLabels;

  const FormStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.primaryClr 
                      : AppColors.greyClr.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            );
          } else {
            // Step indicator
            final stepIndex = index ~/ 2;
            final step = steps[stepIndex];
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;
            
            return _StepIndicator(
              step: step,
              stepNumber: stepIndex + 1,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              showLabel: showLabels,
            );
          }
        }),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final FormStep step;
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool showLabel;

  const _StepIndicator({
    required this.step,
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
                ? AppColors.primaryClr 
                : isCurrent 
                    ? AppColors.primaryClr.withValues(alpha: 0.15)
                    : AppColors.greyClr.withValues(alpha: 0.1),
            border: Border.all(
              color: isCompleted || isCurrent 
                  ? AppColors.primaryClr 
                  : AppColors.greyClr.withValues(alpha: 0.3),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 16.sp,
                    color: Colors.white,
                  )
                : step.icon != null
                    ? Icon(
                        step.icon,
                        size: 14.sp,
                        color: isCurrent 
                            ? AppColors.primaryClr 
                            : AppColors.greyClr,
                      )
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isCurrent 
                              ? AppColors.primaryClr 
                              : AppColors.greyClr,
                        ),
                      ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: 4.h),
          SizedBox(
            width: 50.w,
            child: Text(
              step.label,
              style: AppTextStyles.font10GreyRegular(context).copyWith(
                color: isCompleted || isCurrent 
                    ? AppColors.primaryClr 
                    : AppColors.greyClr,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// Represents a single step in the form
class FormStep {
  final String label;
  final IconData? icon;
  final GlobalKey? fieldKey;

  const FormStep({
    required this.label,
    this.icon,
    this.fieldKey,
  });
}

/// A compact version of the stepper showing just dots
class FormStepperDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const FormStepperDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          width: isCurrent ? 32.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            gradient: isCompleted || isCurrent
                ? LinearGradient(
                    colors: [
                      AppColors.primaryClr,
                      AppColors.primaryClr.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isCompleted || isCurrent 
                ? null
                : AppColors.greyClr.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primaryClr.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

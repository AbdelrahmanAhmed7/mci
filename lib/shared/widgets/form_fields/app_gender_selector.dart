import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';

class AppGenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  const AppGenderSelector({
    super.key,
    this.selectedGender,
    required this.onGenderChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedGender,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'personal_info.gender'.tr(),
                style: AppTextStyles.font14BlackMedium(context),
                children: isRequired
                    ? [
                        TextSpan(
                          text: ' *',
                          style: AppTextStyles.font12BlackRegular(
                            context,
                          ).copyWith(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),

            SizedBox(height: 8.h),

            RadioGroup<String>(
              groupValue: fieldState.value,
              onChanged: (value) {
                if (value != null) {
                  onGenderChanged(value);
                  fieldState.didChange(value);
                  fieldState.validate();
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(context: context, gender: 'Male'),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildGenderOption(
                      context: context,
                      gender: 'Female',
                    ),
                  ),
                ],
              ),
            ),

            if (fieldState.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 8.w),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(color: AppColors.errorClr, fontSize: 12.sp),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGenderOption({
    required BuildContext context,
    required String gender,
  }) {
    final displayLabel = gender == 'Male'
        ? 'personal_info.male'.tr()
        : 'personal_info.female'.tr();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<String>(value: gender, activeColor: AppColors.primaryClr),
        Text(displayLabel, style: AppTextStyles.font12BlackRegular(context)),
      ],
    );
  }
}

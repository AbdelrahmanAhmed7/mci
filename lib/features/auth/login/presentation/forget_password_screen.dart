import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/utils/language_helper.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/cubit/send_otp_cubit.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/send_otp_state.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FigmaAuthPage(
    child: Form(
      key: _formKey,
      child: Stack(
        children: [
          const Positioned(
            left: 58,
            top: 199,
            child: FigmaAuthTitle(
              title: 'Reset password',
              description:
                  'Enter your phone number and we\'ll send you a verification code.',
            ),
          ),
          const Positioned(
            left: 17,
            top: 408,
            child: Text(
              'Phone number',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1C1C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 431,
            child: FigmaAuthTextField(
              controller: _phone,
              hintText: '01001234567',
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter your phone number'
                  : null,
            ),
          ),
          Positioned(
            left: 17,
            top: 538,
            child: BlocConsumer<SendOtpCubit, SendOtpState>(
              listener: (context, state) {
                if (state is Success) {
                  showAppSnackBar(
                    context,
                    'auth.forgot_password.otp_sent_success'.tr(),
                  );
                  context.push('/otp-password', extra: _phone.text.trim());
                }
                if (state is Failed)
                  showAppSnackBar(context, state.error, isError: true);
              },
              builder: (context, state) => Column(
                children: [
                  FigmaAuthButton(
                    text: 'Send Code',
                    loading: state is Loading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      context.read<SendOtpCubit>().sendOtp(
                        LanguageHelper.convertArabicToEnglishNumerals(
                          _phone.text.trim(),
                        ),
                        context.locale.languageCode,
                      );
                    },
                  ),
                  const SizedBox(height: 9),
                  FigmaAuthBackLink(
                    text: 'Back to Sign in',
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

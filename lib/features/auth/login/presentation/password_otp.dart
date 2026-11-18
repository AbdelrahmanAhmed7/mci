import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:mediconsult/core/theming/figma_colors.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/cubit/resend_otp_cubit.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/cubit/verify_otp_cubit.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/resend_otp_state.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/verify_otp_state.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';

class PasswordOtpScreen extends StatefulWidget {
  final String phoneNumber;
  const PasswordOtpScreen({super.key, required this.phoneNumber});
  @override
  State<PasswordOtpScreen> createState() => _PasswordOtpScreenState();
}

class _PasswordOtpScreenState extends State<PasswordOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  Timer? _timer;
  int _seconds = 38;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds == 0) {
        _timer?.cancel();
      } else if (mounted)
        setState(() => _seconds--);
    });
  }

  String get _time =>
      '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}';
  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
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
              title: 'Verify your phone',
              description: 'Enter the verification code we sent to your phone.',
            ),
          ),
          Positioned(
            left: 17,
            top: 319,
            child: Pinput(
              controller: _otp,
              length: 4,
              defaultPinTheme: PinTheme(
                width: 89,
                height: 54,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.neutral900,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: FigmaColors.neutral200),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 89,
                height: 54,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.neutral900,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: FigmaColors.blue500, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value == null || value.length != 4 ? '' : null,
              keyboardType: TextInputType.number,
            ),
          ),
          Positioned(
            left: 17,
            top: 389,
            width: 388,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code expires in $_time',
                  style: const TextStyle(
                    fontSize: 13,
                    color: FigmaColors.neutral500,
                  ),
                ),
                BlocConsumer<ResendOtpCubit, ResendOtpState>(
                  listener: (context, state) {
                    if (state is ResendFailed)
                      showAppSnackBar(context, state.error, isError: true);
                  },
                  builder: (context, state) => GestureDetector(
                    onTap: _seconds == 0
                        ? () {
                            setState(() => _seconds = 38);
                            _startTimer();
                            context.read<ResendOtpCubit>().resendOtp(
                              widget.phoneNumber,
                              context.locale.languageCode,
                            );
                          }
                        : null,
                    child: Text(
                      'Resend code',
                      style: TextStyle(
                        fontSize: 13,
                        color: _seconds == 0
                            ? FigmaColors.blue500
                            : FigmaColors.neutral400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            top: 431,
            child: BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
              listener: (context, state) {
                if (state is Success) {
                  showAppSnackBar(
                    context,
                    'auth.forgot_password.otp_verified'.tr(),
                  );
                  context.push('/reset-password', extra: widget.phoneNumber);
                }
                if (state is Failed)
                  showAppSnackBar(context, state.error, isError: true);
              },
              builder: (context, state) => Column(
                children: [
                  FigmaAuthButton(
                    text: 'Verify',
                    loading: state is Loading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      context.read<VerifyOtpCubit>().verifyOtp(
                        widget.phoneNumber,
                        _otp.text,
                        context.locale.languageCode,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FigmaAuthBackLink(
                    text: 'Use a different account',
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

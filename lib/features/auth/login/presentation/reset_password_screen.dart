import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/utils/language_helper.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/cubit/reset_password_cubit.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/reset_password/reset_password_state.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  const ResetPasswordScreen({super.key, required this.phoneNumber});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _success() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Password changed', textAlign: TextAlign.center),
        content: const Text(
          'Your password was changed successfully.',
          textAlign: TextAlign.center,
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        context.go('/login');
      }
    });
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
              title: 'Create New password',
              description: 'Set a new password to keep your account secure.',
            ),
          ),
          const Positioned(
            left: 17,
            top: 319,
            child: Text(
              'New password',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1C1C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: 17,
            top: 340,
            child: FigmaAuthTextField(
              controller: _password,
              hintText: 'Enter new password',
              obscureText: true,
              helperText: 'Your password must be at least 8 characters',
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter a new password';
                if (value.length < 8)
                  return 'Password must be at least 8 characters';
                return null;
              },
            ),
          ),
          const Positioned(
            left: 17,
            top: 452,
            child: Text(
              'Confirm password',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1C1C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: 17,
            top: 473,
            child: FigmaAuthTextField(
              controller: _confirm,
              hintText: 'Re-enter new password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please confirm your password';
                if (value != _password.text) return 'Passwords do not match';
                return null;
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 538,
            child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
              listener: (context, state) {
                if (state is Success) _success();
                if (state is Failed)
                  showAppSnackBar(context, state.error, isError: true);
              },
              builder: (context, state) => Column(
                children: [
                  FigmaAuthButton(
                    text: 'Reset',
                    loading: state is Loading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      context.read<ResetPasswordCubit>().resetPassword(
                        widget.phoneNumber,
                        LanguageHelper.convertArabicToEnglishNumerals(
                          _password.text.trim(),
                        ),
                        LanguageHelper.convertArabicToEnglishNumerals(
                          _confirm.text.trim(),
                        ),
                        context.locale.languageCode,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
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

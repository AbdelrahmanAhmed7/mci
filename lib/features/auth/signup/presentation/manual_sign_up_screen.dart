import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/core/utils/language_helper.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';
import 'package:mediconsult/features/auth/signup/presentation/logic/signup_cubit.dart';
import 'package:mediconsult/features/auth/signup/presentation/logic/signup_state.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';

class ManualSignUpScreen extends StatefulWidget {
  const ManualSignUpScreen({super.key});

  @override
  State<ManualSignUpScreen> createState() => _ManualSignUpScreenState();
}

class _ManualSignUpScreenState extends State<ManualSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _card = TextEditingController();
  final _national = TextEditingController();
  final _passport = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _card.dispose();
    _national.dispose();
    _passport.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    bool password = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 6),
          FigmaAuthTextField(
            controller: controller,
            hintText: hint,
            obscureText: password,
            keyboardType: keyboardType,
            validator: validator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FigmaAccountPage(
      step: 'Step 3/4',
      onBack: () => context.pop(),
      child: Stack(
        children: [
          const FigmaProgress(activeStep: 3),
          Positioned(
            left: 16,
            top: 179,
            width: 397,
            height: 700,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your membership details',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your details carefully. You can review them before continuing.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        height: 1.45,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _field(
                      'MCI / Member ID',
                      _card,
                      'Enter MCI or member ID',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your MCI or member ID'
                          : null,
                    ),
                    _field(
                      'National ID',
                      _national,
                      'Enter national ID',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) &&
                              _passport.text.trim().isEmpty
                          ? 'Enter national ID or passport number'
                          : null,
                    ),
                    _field(
                      'Passport number (optional)',
                      _passport,
                      'Enter passport number',
                    ),
                    _field(
                      'Phone number',
                      _phone,
                      'Enter phone number',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your phone number'
                          : null,
                    ),
                    _field(
                      'Password',
                      _password,
                      'Enter password',
                      password: true,
                      validator: (v) => v == null || v.length < 8
                          ? 'Password must be at least 8 characters'
                          : null,
                    ),
                    _field(
                      'Confirm password',
                      _confirm,
                      'Re-enter password',
                      password: true,
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                    BlocConsumer<SignupCubit, SignupState>(
                      listener: (context, state) {
                        if (state is Success) {
                          showAppSnackBar(
                            context,
                            'auth.signup.registration_successful'.tr(),
                          );
                          context.go('/home');
                        }
                        if (state is Failed)
                          showAppSnackBar(context, state.error, isError: true);
                      },
                      builder: (context, state) => FigmaAuthButton(
                        text: 'Create Account',
                        loading: state is Loading,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          context.read<SignupCubit>().signup(
                            LanguageHelper.convertArabicToEnglishNumerals(
                              _card.text.trim(),
                            ),
                            _national.text.trim().isEmpty
                                ? null
                                : LanguageHelper.convertArabicToEnglishNumerals(
                                    _national.text.trim(),
                                  ),
                            _passport.text.trim().isEmpty
                                ? null
                                : LanguageHelper.convertArabicToEnglishNumerals(
                                    _passport.text.trim(),
                                  ),
                            LanguageHelper.convertArabicToEnglishNumerals(
                              _phone.text.trim(),
                            ),
                            _password.text.trim(),
                            _confirm.text.trim(),
                            context.locale.languageCode,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: FigmaAuthBackLink(
                        text: 'Back to Sign in',
                        onPressed: () => context.go('/login'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

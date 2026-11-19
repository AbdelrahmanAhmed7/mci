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
  bool _showAgreements = false;
  bool _termsAccepted = false;
  bool _healthDataAccepted = false;

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

  Widget _agreementCard({
    required String text,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      width: 399,
      height: 55,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: const CircleBorder(),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              activeColor: const Color(0xFF5983F3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
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
                    if (!_showAgreements) ...[
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
                        validator: (v) => v != _password.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      FigmaAuthButton(
                        text: 'Continue',
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _showAgreements = true);
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Your membership details',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D0D0D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check every field — you can correct anything before continuing.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _agreementCard(
                        text: 'I accept the Terms of Service',
                        value: _termsAccepted,
                        onChanged: (value) =>
                            setState(() => _termsAccepted = value ?? false),
                      ),
                      const SizedBox(height: 12),
                      _agreementCard(
                        text: 'I consent to processing of my health data',
                        value: _healthDataAccepted,
                        onChanged: (value) => setState(
                          () => _healthDataAccepted = value ?? false,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BlocConsumer<SignupCubit, SignupState>(
                        listener: (context, state) {
                          if (state is Success) {
                            showAppSnackBar(
                              context,
                              'auth.signup.registration_successful'.tr(),
                            );
                            context.go('/account-verified');
                          }
                          if (state is Failed)
                            showAppSnackBar(
                              context,
                              state.error,
                              isError: true,
                            );
                        },
                        builder: (context, state) => FigmaAuthButton(
                          text: 'Create Account',
                          loading: state is Loading,
                          onPressed: !_termsAccepted || !_healthDataAccepted
                              ? null
                              : () {
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
                          text: 'Back to details',
                          onPressed: () => setState(() {
                            _showAgreements = false;
                            _termsAccepted = false;
                            _healthDataAccepted = false;
                          }),
                        ),
                      ),
                    ],
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

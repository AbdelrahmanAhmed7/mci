import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/utils/language_helper.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/login_cubit.dart';
import 'package:mediconsult/features/auth/login/presentation/logic/login_state.dart';
import 'package:mediconsult/features/auth/login/presentation/widgets/figma_auth_widgets.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FigmaAuthPage(
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              const Positioned(
                left: 58,
                top: 199,
                child: FigmaAuthTitle(
                  title: 'Welcome back',
                  description: 'Sign in to your Mediconsult Membership',
                ),
              ),
              Positioned(
                left: 36,
                top: 296,
                width: 358,
                height: 44,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['Phone', 'MCI ID', 'National ID']
                        .asMap()
                        .entries
                        .map((entry) {
                          final selected = _tab == entry.key;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = entry.key),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFE8EFFD)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selected
                                        ? const Color(0xFF3860F0)
                                        : const Color(0xFF747474),
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
              const Positioned(
                left: 17,
                top: 366,
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
                left: 17,
                top: 387,
                child: FigmaAuthTextField(
                  controller: _identifier,
                  hintText: _tab == 0
                      ? '01001234567'
                      : (_tab == 1 ? '2000000' : '29801010101010'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your ID or phone number'
                      : null,
                ),
              ),
              const Positioned(
                left: 17,
                top: 452,
                child: Text(
                  'Password',
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
                  controller: _password,
                  hintText: 'Enter your password',
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your password'
                      : null,
                ),
              ),
              Positioned(
                left: 17,
                top: 571,
                child: BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state is Success) {
                      showAppSnackBar(
                        context,
                        'auth.login.login_successful'.tr(),
                      );
                      context.go('/home');
                    }
                    if (state is Failed)
                      showAppSnackBar(context, state.error, isError: true);
                  },
                  builder: (context, state) => Column(
                    children: [
                      FigmaAuthButton(
                        text: 'Login',
                        loading: state is Loading,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          context.read<LoginCubit>().login(
                            LanguageHelper.convertArabicToEnglishNumerals(
                              _identifier.text.trim(),
                            ),
                            LanguageHelper.convertArabicToEnglishNumerals(
                              _password.text.trim(),
                            ),
                            context.locale.languageCode,
                          );
                        },
                      ),
                      const SizedBox(height: 9),
                      FigmaAuthBackLink(
                        text: 'Forgot password?',
                        onPressed: () => context.push('/forget-password'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 862,
                width: 384,
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'New to MediConsult? ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF747474),
                      ),
                      children: [
                        TextSpan(
                          text: 'Create an account',
                          style: const TextStyle(color: Color(0xFF5983F3)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/signup'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

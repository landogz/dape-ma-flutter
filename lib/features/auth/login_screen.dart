import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verification_code_screen.dart';
import 'widgets/auth_decor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      // Verification UI preview only — no OTP API yet.
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(
            destination: _emailController.text.trim(),
          ),
        ),
      );
      if (!mounted) return;
      if (verified == true) {
        Navigator.of(context).pop(true);
      } else {
        // User backed out of preview; still treat login as successful.
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.loginFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _socialComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.socialLoginComingSoon)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: AuthDecorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: AppColors.secondaryBlue,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 88,
                            height: 88,
                            child: SvgPicture.asset(
                              'assets/ddb.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'DAPE-MA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondaryBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.welcomeBackExclaim,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.secondaryBlue,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginJourneySubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryBlue.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          decoration: authFieldDecoration(
                            context: context,
                            hintText: l10n.enterEmailHint,
                            prefixIcon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.emailRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          decoration: authFieldDecoration(
                            context: context,
                            hintText: l10n.enterPasswordHint,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.primaryBlue.withValues(alpha: 0.7),
                                size: 22,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.passwordRequired;
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.accentRed,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AuthPrimaryButton(
                          label: l10n.signIn,
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                            child: Text(
                              l10n.forgotPassword,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFFD7E3F0))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                l10n.orDivider,
                                style: TextStyle(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFFD7E3F0))),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(
                              onTap: _socialComingSoon,
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  color: Color(0xFFEA4335),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _SocialButton(
                              onTap: _socialComingSoon,
                              child: const Icon(
                                Icons.facebook_rounded,
                                color: Color(0xFF1877F2),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _SocialButton(
                              onTap: _socialComingSoon,
                              child: const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Color(0x66000000),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      final nav = Navigator.of(context);
                                      final result = await nav.push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                      if (!mounted || result != true) return;
                                      nav.pop(true);
                                    },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: AppColors.accentYellow,
                              ),
                              child: Text(
                                l10n.register,
                                style: const TextStyle(
                                  color: AppColors.accentYellow,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x66000000),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(child: child),
        ),
      ),
    );
  }
}

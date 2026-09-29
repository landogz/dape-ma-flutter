import 'package:flutter/material.dart';

import '../../core/auth/auth_navigator.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/theme/app_colors.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verification_code_screen.dart';
import 'widgets/auth_decor.dart';
import 'widgets/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.asAuthGate = false,
    this.initialPosts = const [],
  });

  /// When true, this screen is the app root for guests (no back to home).
  final bool asAuthGate;

  /// Prefetched posts from splash to pass into the welcome screen after login.
  final List<Post> initialPosts;

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

  void _enterAppOrPop() {
    if (widget.asAuthGate) {
      AuthNavigator.enterApp(context, posts: widget.initialPosts);
      return;
    }
    Navigator.of(context).pop(true);
  }

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

      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(
            destination: _emailController.text.trim(),
          ),
        ),
      );
      if (!mounted) return;
      _enterAppOrPop();
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

    return AuthScaffold(
      canPop: !widget.asAuthGate,
      showBack: !widget.asAuthGate,
      onBack: _loading ? null : () => Navigator.of(context).maybePop(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandMark(),
            const SizedBox(height: 28),
            AuthHeadline(l10n.welcomeBackExclaim),
            const SizedBox(height: 10),
            AuthSubtext(l10n.loginJourneySubtitle),
            const SizedBox(height: 28),
            AuthFieldShell(
              child: TextFormField(
                controller: _emailController,
                decoration: authFieldDecoration(
                  context: context,
                  hintText: l10n.enterEmailHint,
                  prefixIcon: Icons.email_outlined,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AuthTokens.inputText,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_loading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailRequired;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            AuthFieldShell(
              child: TextFormField(
                controller: _passwordController,
                decoration: authFieldDecoration(
                  context: context,
                  hintText: l10n.enterPasswordHint,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.mediumElectricBlue,
                      size: 22,
                    ),
                    onPressed: _loading
                        ? null
                        : () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AuthTokens.inputText,
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !_loading,
                onFieldSubmitted: (_) {
                  if (!_loading) _submit();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.passwordRequired;
                  }
                  return null;
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AuthBanner(message: _error!),
            ],
            const SizedBox(height: 24),
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
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumElectricBlue,
                  minimumSize: const Size(44, 44),
                ),
                child: Text(
                  l10n.forgotPassword,
                  style: const TextStyle(
                    color: AppColors.mediumElectricBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AuthOrDivider(label: l10n.orDivider),
            const SizedBox(height: 20),
            AuthSocialCircleRow(
              onTap: _socialComingSoon,
              enabled: !_loading,
            ),
            const SizedBox(height: 28),
            AuthFooterFade(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.noAccount,
                    style: const TextStyle(
                      color: AuthTokens.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final result = await Navigator.of(context)
                                .push<bool>(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                            if (!mounted || result != true) return;
                            _enterAppOrPop();
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(44, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.nileBlue,
                    ),
                    child: Text(
                      l10n.register,
                      style: const TextStyle(
                        color: AppColors.nileBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

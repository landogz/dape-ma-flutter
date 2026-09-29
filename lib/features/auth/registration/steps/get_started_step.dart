import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_decor.dart';
import '../../widgets/auth_scaffold.dart';

class GetStartedStep extends StatefulWidget {
  const GetStartedStep({
    super.key,
    required this.onContinue,
    required this.loading,
    this.error,
  });

  final Future<void> Function({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) onContinue;
  final bool loading;
  final String? error;

  @override
  State<GetStartedStep> createState() => _GetStartedStepState();
}

class _GetStartedStepState extends State<GetStartedStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onContinue(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
  }

  void _socialSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.socialLoginComingSoon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AuthBrandMark(sealSize: 88),
          const SizedBox(height: 28),
          AuthHeadline(l10n.regGetStartedTitle, center: false),
          const SizedBox(height: 10),
          AuthSubtext(l10n.regGetStartedSubtitle, center: false),
          const SizedBox(height: 28),
          AuthFieldShell(
            child: TextFormField(
              controller: _emailController,
              enabled: !widget.loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15, color: AuthTokens.inputText),
              decoration: authFieldDecoration(
                context: context,
                hintText: l10n.enterEmailHint,
                prefixIcon: Icons.email_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.emailRequired;
                return null;
              },
            ),
          ),
          const SizedBox(height: 14),
          AuthFieldShell(
            child: TextFormField(
              controller: _passwordController,
              enabled: !widget.loading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15, color: AuthTokens.inputText),
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
                  onPressed: widget.loading
                      ? null
                      : () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.mediumElectricBlue,
                    size: 22,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 8) return l10n.passwordMinSix;
                return null;
              },
            ),
          ),
          const SizedBox(height: 14),
          AuthFieldShell(
            child: TextFormField(
              controller: _confirmController,
              enabled: !widget.loading,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!widget.loading) _submit();
              },
              style: const TextStyle(fontSize: 15, color: AuthTokens.inputText),
              decoration: authFieldDecoration(
                context: context,
                hintText: l10n.confirmPassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: widget.loading
                      ? null
                      : () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.mediumElectricBlue,
                    size: 22,
                  ),
                ),
              ),
              validator: (v) {
                if (v != _passwordController.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
          ),
          if (widget.error != null && widget.error!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            AuthBanner(message: widget.error!),
          ],
          const SizedBox(height: 16),
          AuthLegalLine(
            prefix: l10n.authAgreePrefix,
            termsLabel: l10n.termsOfUse,
            andLabel: l10n.authAgreeAnd,
            privacyLabel: l10n.privacyPolicy,
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            label: l10n.continueLabel,
            loading: widget.loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 20),
          AuthOrDivider(label: l10n.orDivider),
          const SizedBox(height: 20),
          AuthSocialCircleRow(
            onTap: _socialSoon,
            enabled: !widget.loading,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

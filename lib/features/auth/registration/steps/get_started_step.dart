import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_decor.dart';

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
          Text(
            l10n.regGetStartedTitle,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.regGetStartedSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
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
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              context: context,
              hintText: l10n.enterPasswordHint,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 6) return l10n.passwordMinSix;
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: authFieldDecoration(
              context: context,
              hintText: l10n.confirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primaryBlue,
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
          if (widget.error != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.error!,
              style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
            ),
          ],
          const SizedBox(height: 22),
          AuthPrimaryButton(
            label: l10n.continueLabel,
            loading: widget.loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFD7E3F0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.orDivider,
                  style: TextStyle(
                    color: AppColors.primaryBlue.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFD7E3F0))),
            ],
          ),
          const SizedBox(height: 16),
          _SocialContinueButton(
            label: l10n.regContinueGoogle,
            onTap: _socialSoon,
            leading: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFFEA4335),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SocialContinueButton(
            label: l10n.regContinueFacebook,
            onTap: _socialSoon,
            leading: const Icon(
              Icons.facebook_rounded,
              color: Color(0xFF1877F2),
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          _SocialContinueButton(
            label: l10n.regContinueApple,
            onTap: _socialSoon,
            leading: const Icon(Icons.apple, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SocialContinueButton extends StatelessWidget {
  const _SocialContinueButton({
    required this.label,
    required this.onTap,
    required this.leading,
  });

  final String label;
  final VoidCallback onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              SizedBox(width: 28, child: Center(child: leading)),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
      ),
    );
  }
}

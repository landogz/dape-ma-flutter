import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validation/email_address.dart';
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
    required bool acceptedTermsOfUse,
    required bool acceptedPrivacyPolicy,
    required bool acceptedPrivacyNotice,
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
  bool _acceptedTerms = false;
  bool _acceptedPrivacyPolicy = false;
  bool _acceptedPrivacyNotice = false;
  bool _consentError = false;
  bool _checkingEmail = false;
  String? _emailRemoteError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _allAccepted =>
      _acceptedTerms && _acceptedPrivacyPolicy && _acceptedPrivacyNotice;

  bool get _busy => widget.loading || _checkingEmail;

  Future<void> _submit() async {
    setState(() => _emailRemoteError = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_allAccepted) {
      setState(() => _consentError = true);
      return;
    }

    final email = EmailAddress.normalize(_emailController.text);
    setState(() => _checkingEmail = true);
    try {
      final available = await AuthService.emailIsAvailable(email);
      if (!mounted) return;
      if (!available) {
        setState(() => _emailRemoteError = context.l10n.emailTaken);
        _formKey.currentState?.validate();
        return;
      }
    } on DioException catch (error) {
      if (!mounted) return;
      final status = error.response?.statusCode;
      setState(() {
        _emailRemoteError = status == 422
            ? context.l10n.emailInvalid
            : context.l10n.emailCheckFailed;
      });
      _formKey.currentState?.validate();
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _emailRemoteError = context.l10n.emailCheckFailed);
      _formKey.currentState?.validate();
      return;
    } finally {
      if (mounted) setState(() => _checkingEmail = false);
    }

    await widget.onContinue(
      email: email,
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
      acceptedTermsOfUse: _acceptedTerms,
      acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
      acceptedPrivacyNotice: _acceptedPrivacyNotice,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              style: const TextStyle(fontSize: 15, color: AuthTokens.inputText),
              decoration: authFieldDecoration(
                context: context,
                hintText: l10n.enterEmailHint,
                prefixIcon: Icons.email_outlined,
              ),
              onChanged: (_) {
                if (_emailRemoteError != null) {
                  setState(() => _emailRemoteError = null);
                }
              },
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.emailRequired;
                if (!EmailAddress.isValid(v)) return l10n.emailInvalid;
                return _emailRemoteError;
              },
            ),
          ),
          const SizedBox(height: 14),
          AuthFieldShell(
            child: TextFormField(
              controller: _passwordController,
              enabled: !_busy,
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
                  onPressed: _busy
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
              enabled: !_busy,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_busy) _submit();
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
                  onPressed: _busy
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
          AuthConsentChecks(
            acceptedTerms: _acceptedTerms,
            acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
            acceptedPrivacyNotice: _acceptedPrivacyNotice,
            enabled: !_busy,
            showError: _consentError,
            onAcceptedTermsChanged: (value) {
              setState(() {
                _acceptedTerms = value;
                if (_allAccepted) _consentError = false;
              });
            },
            onAcceptedPrivacyPolicyChanged: (value) {
              setState(() {
                _acceptedPrivacyPolicy = value;
                if (_allAccepted) _consentError = false;
              });
            },
            onAcceptedPrivacyNoticeChanged: (value) {
              setState(() {
                _acceptedPrivacyNotice = value;
                if (_allAccepted) _consentError = false;
              });
            },
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            label: l10n.continueLabel,
            loading: _busy,
            onPressed: (_busy || !_allAccepted) ? null : _submit,
          ),
          const SizedBox(height: 20),
          AuthOrDivider(label: l10n.orDivider),
          const SizedBox(height: 20),
          AuthSocialCircleRow(
            onTap: _socialSoon,
            enabled: !_busy,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

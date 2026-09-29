import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/auth_decor.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final api = ApiClient();
      await api.post<Map<String, dynamic>>(
        Endpoints.forgotPassword,
        data: <String, dynamic>{
          'email': _emailController.text.trim(),
        },
      );
      if (!mounted) return;
      setState(() => _success = context.l10n.resetSuccess);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.resetFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthScaffold(
      showBack: true,
      title: l10n.forgotPassword,
      centerContent: true,
      onBack: _loading ? null : () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandMark(sealSize: 88),
            const SizedBox(height: 28),
            AuthHeadline(l10n.forgotPassword),
            const SizedBox(height: 10),
            AuthSubtext(l10n.resetInstructions),
            const SizedBox(height: 28),
            AuthFieldShell(
              child: TextFormField(
                controller: _emailController,
                enabled: !_loading,
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_loading) _submit();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailRequired;
                  }
                  return null;
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AuthBanner(message: _error!),
            ],
            if (_success != null) ...[
              const SizedBox(height: 12),
              AuthBanner(message: _success!, isError: false),
            ],
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: l10n.sendResetLink,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            AuthFooterFade(
              child: Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mediumElectricBlue,
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(
                    l10n.backToLogin,
                    style: const TextStyle(
                      color: AppColors.mediumElectricBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

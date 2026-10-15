import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/auth_decor.dart';
import 'widgets/auth_scaffold.dart';
import '../../core/theme/app_theme_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  final String email;
  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
      final res = await api.post<Map<String, dynamic>>(
        Endpoints.resetPassword,
        data: <String, dynamic>{
          'email': widget.email,
          'token': widget.token,
          'password': _passwordController.text,
          'password_confirmation': _confirmController.text,
        },
      );
      if (!mounted) return;
      final message = (res.data?['message'] as String?)?.trim();
      setState(() {
        _success = (message != null && message.isNotEmpty)
            ? message
            : context.l10n.passwordResetSuccess;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on DioException catch (e) {
      if (!mounted) return;
      final apiMessage = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      setState(() {
        _error = (apiMessage != null && apiMessage.isNotEmpty)
            ? apiMessage
            : context.l10n.passwordResetFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.passwordResetFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthScaffold(
      showBack: true,
      title: l10n.resetPassword,
      centerContent: true,
      onBack: _loading ? null : () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandMark(sealSize: 88),
            const SizedBox(height: 28),
            AuthHeadline(l10n.resetPassword),
            const SizedBox(height: 10),
            AuthSubtext(l10n.resetPasswordSubtitle),
            const SizedBox(height: 8),
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.heading,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            AuthFieldShell(
              child: TextFormField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: _obscurePassword,
                decoration: authFieldDecoration(
                  context: context,
                  hintText: l10n.newPasswordHint,
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
                        : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AuthTokens.inputText,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.passwordRequired;
                  }
                  if (value.length < 8) {
                    return l10n.passwordMinEight;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            AuthFieldShell(
              child: TextFormField(
                controller: _confirmController,
                enabled: !_loading,
                obscureText: _obscureConfirm,
                decoration: authFieldDecoration(
                  context: context,
                  hintText: l10n.confirmPasswordHint,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.mediumElectricBlue,
                      size: 22,
                    ),
                    onPressed: _loading
                        ? null
                        : () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AuthTokens.inputText,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_loading) _submit();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.passwordRequired;
                  }
                  if (value != _passwordController.text) {
                    return l10n.passwordsDoNotMatch;
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
              label: l10n.saveNewPassword,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            AuthFooterFade(
              child: Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          ),
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

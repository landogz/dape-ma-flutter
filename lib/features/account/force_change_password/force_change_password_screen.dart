import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_entry.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/validation/password_policy/password_policy.dart';

class ForceChangePasswordScreen extends StatefulWidget {
  const ForceChangePasswordScreen({super.key, this.initialPosts = const []});

  final List<Post> initialPosts;

  @override
  State<ForceChangePasswordScreen> createState() =>
      _ForceChangePasswordScreenState();
}

class _ForceChangePasswordScreenState extends State<ForceChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      setState(() => _error = l10n.currentPasswordRequired);
      return;
    }
    if (!PasswordPolicy.isValid(newPass)) {
      setState(() => _error = l10n.passwordPolicyHint);
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.authedPut<Map<String, dynamic>>(
        Endpoints.changePassword,
        data: <String, dynamic>{
          'current_password': current,
          'password': newPass,
          'password_confirmation': confirm,
        },
      );
      AuthService.mustChangePassword = false;
      if (!mounted) return;
      await AppEntry.enter(context, posts: widget.initialPosts);
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      setState(() {
        _error = (message != null && message.isNotEmpty)
            ? message
            : l10n.passwordUpdateFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.passwordUpdateFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: context.cardBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: context.pageBackground,
          foregroundColor: context.heading,
          elevation: 0,
          centerTitle: true,
          title: Text(l10n.passwordMustChangeTitle),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(
                l10n.passwordMustChangeBody,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.passwordPolicyHint,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                decoration: inputDecoration.copyWith(
                  labelText: l10n.currentPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newController,
                obscureText: _obscureNew,
                decoration: inputDecoration.copyWith(
                  labelText: l10n.newPassword,
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: inputDecoration.copyWith(
                  labelText: l10n.confirmNewPassword,
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.updatePassword),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/auth_header.dart';

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
      setState(() {
        _success = context.l10n.resetSuccess;
      });
    } catch (_) {
      setState(() {
        _error = context.l10n.resetFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const AuthHeader(),
                const SizedBox(height: 24),
                Text(
                  l10n.resetInstructions,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: inputDecoration.copyWith(
                    labelText: l10n.email,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondaryLight,
                      size: 22,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.emailRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.accentRed,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                if (_success != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _success!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
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
                        : Text(l10n.sendResetLink),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: Text(
                      l10n.backToLogin,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

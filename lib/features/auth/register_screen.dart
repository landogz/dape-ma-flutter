import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final res = e.response?.data;
      final message = res is Map && res['message'] != null
          ? res['message'] as String
          : null;
      final errors = res is Map && res['errors'] is Map
          ? res['errors'] as Map<String, dynamic>
          : null;
      String? errMsg = message;
      if (errMsg == null && errors != null && errors.isNotEmpty) {
        final first = errors.values.first;
        errMsg = first is List && first.isNotEmpty
            ? first.first as String
            : first?.toString();
      }
      if (mounted) {
        setState(() {
          _error = errMsg?.isNotEmpty == true
              ? errMsg!
              : context.l10n.registrationFailed;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = context.l10n.registrationFailed;
        });
      }
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
        title: Text(l10n.register),
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
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: inputDecoration.copyWith(
                    labelText: l10n.name,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondaryLight,
                      size: 22,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.emailRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: inputDecoration.copyWith(
                    labelText: l10n.password,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondaryLight,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondaryLight,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return l10n.passwordMinSix;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: inputDecoration.copyWith(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondaryLight,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondaryLight,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordConfirm = !_obscurePasswordConfirm;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePasswordConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return l10n.passwordsDoNotMatch;
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
                        : Text(l10n.createAccount),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.login,
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
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


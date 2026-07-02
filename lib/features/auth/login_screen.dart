import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/auth_header.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

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
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = context.l10n.loginFailed;
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
        title: Text(l10n.login),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
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
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
                        : Text(l10n.signIn),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.noAccount,
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              final result = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                              if (mounted && result == true) {
                                Navigator.of(context).pop(true);
                              }
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.register,
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

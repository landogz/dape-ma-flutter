import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import 'verification_success_screen.dart';
import 'widgets/auth_decor.dart';

/// UI-only verification step. Does not call any OTP API yet.
class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({
    super.key,
    required this.destination,
  });

  final String destination;

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  static const _length = 6;
  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_length, (_) => FocusNode());
  int _secondsLeft = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _continuePreview() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const VerificationSuccessScreen(),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: AuthDecorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: AppColors.secondaryBlue,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: Column(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 42,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.enterVerificationCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.secondaryBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.verificationCodeSentTo(widget.destination),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryBlue.withValues(alpha: 0.8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.verificationPreviewNote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_length, (index) {
                          return SizedBox(
                            width: 46,
                            height: 54,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondaryBlue,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: context.inputFill,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD7E3F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD7E3F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.6,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < _length - 1) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                setState(() {});
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      AuthPrimaryButton(
                        label: l10n.verifyCode,
                        onPressed: _continuePreview,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.didntReceiveCode,
                            style: TextStyle(
                              color: context.textSecondary
                                  .withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (_secondsLeft > 0)
                            Text(
                              l10n.resendIn(_timerLabel),
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _startTimer,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.resendCode,
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_code.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _code,
                          style: TextStyle(
                            color: AppColors.primaryBlue.withValues(alpha: 0.35),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import 'steps/birthday_step.dart';
import 'steps/get_started_step.dart';
import 'steps/interests_step.dart';
import 'steps/nickname_step.dart';
import 'steps/persona_step.dart';
import 'steps/success_step.dart';
import 'widgets/registration_shell.dart';

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key});

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  int _step = 0;
  bool _loading = false;
  String? _step1Error;

  final _nicknameController = TextEditingController();
  String? _pronouns;
  DateTime? _birthday;
  String? _persona;
  final Set<String> _interests = {};

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String _provisionalNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'DAPE User';
    return local.length > 40 ? local.substring(0, 40) : local;
  }

  String? _dioMessage(DioException e) {
    final res = e.response?.data;
    if (res is Map) {
      final rawMessage = res['message'];
      final message = rawMessage is String ? rawMessage.trim() : null;
      final errors = res['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          final text = first.first.toString().trim();
          if (text.isNotEmpty) return text;
        } else if (first != null) {
          final text = first.toString().trim();
          if (text.isNotEmpty) return text;
        }
      }
      if (message != null && message.isNotEmpty) return message;

      // 404 / empty framework messages (wrong API host, missing route)
      final status = e.response?.statusCode;
      if (status == 404) {
        return 'Registration service unavailable. Check the API server.';
      }
      if (status == 422) {
        return 'Please check your email and password and try again.';
      }
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the server. Make sure the API is running.';
    }
    return null;
  }

  Future<void> _register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    setState(() {
      _loading = true;
      _step1Error = null;
    });
    try {
      await AuthService.register(
        name: _provisionalNameFromEmail(email),
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (!mounted) return;
      setState(() => _step = 1);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _step1Error = _dioMessage(e) ?? context.l10n.registrationFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _step1Error = context.l10n.registrationFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _nextFromNickname() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regNicknameRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.updateOnboarding(
        nickname: nickname,
        pronouns: _pronouns,
      );
      if (!mounted) return;
      setState(() => _step = 2);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regOnboardingFailed)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _nextFromBirthday() async {
    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regBirthdayRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.updateOnboarding(
        birthday: DateFormat('yyyy-MM-dd').format(_birthday!),
      );
      if (!mounted) return;
      setState(() => _step = 3);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regOnboardingFailed)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _nextFromPersona() async {
    if (_persona == null || _persona!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regPersonaRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.updateOnboarding(persona: _persona);
      if (!mounted) return;
      setState(() => _step = 4);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regOnboardingFailed)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _nextFromInterests() async {
    if (_interests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regInterestsRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.updateOnboarding(
        interests: _interests.toList(),
        complete: true,
      );
      if (!mounted) return;
      setState(() => _step = 5);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.regOnboardingFailed)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _finish() {
    Navigator.of(context).pop(true);
  }

  void _back() {
    if (_step <= 0) {
      Navigator.of(context).maybePop();
      return;
    }
    // After account creation, do not go back to re-register.
    if (_step == 1) return;
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      0 => RegistrationShell(
          showNextFab: false,
          onBack: () => Navigator.of(context).maybePop(),
          child: GetStartedStep(
            loading: _loading,
            error: _step1Error,
            onContinue: _register,
          ),
        ),
      1 => RegistrationShell(
          showBack: false,
          nextLoading: _loading,
          onNext: _nextFromNickname,
          child: NicknameStep(
            nicknameController: _nicknameController,
            selectedPronouns: _pronouns,
            onPronounsChanged: (v) => setState(() => _pronouns = v),
          ),
        ),
      2 => RegistrationShell(
          nextLoading: _loading,
          onBack: _back,
          onNext: _nextFromBirthday,
          child: BirthdayStep(
            birthday: _birthday,
            onPick: (d) => setState(() => _birthday = d),
          ),
        ),
      3 => RegistrationShell(
          nextLoading: _loading,
          onBack: _back,
          onNext: _nextFromPersona,
          child: PersonaStep(
            selected: _persona,
            onSelect: (v) => setState(() => _persona = v),
          ),
        ),
      4 => RegistrationShell(
          nextLoading: _loading,
          onBack: _back,
          onNext: _nextFromInterests,
          child: InterestsStep(
            selected: _interests,
            onToggle: (key) {
              setState(() {
                if (_interests.contains(key)) {
                  _interests.remove(key);
                } else {
                  _interests.add(key);
                }
              });
            },
          ),
        ),
      _ => RegistrationShell(
          showBack: false,
          showNextFab: false,
          child: SuccessStep(onFinish: _finish),
        ),
    };
  }
}

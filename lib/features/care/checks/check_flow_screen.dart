import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/care_toolkit_question.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../auth/login_screen.dart';
import '../care_colors.dart';
import '../care_toolkit_service.dart';
import 'care_check_service.dart';
import 'widgets/check_intro_view.dart';
import 'widgets/check_question_view.dart';

class CheckFlowScreen extends StatefulWidget {
  const CheckFlowScreen({
    super.key,
    required this.checkType,
  });

  final String checkType;

  @override
  State<CheckFlowScreen> createState() => _CheckFlowScreenState();
}

class _CheckFlowScreenState extends State<CheckFlowScreen> {
  List<CareToolkitQuestion> _questions = [];
  final Map<int, int> _likert = {};
  final Map<int, TimeOfDay> _times = {};
  bool _loading = true;
  bool _started = false;
  bool _saving = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final locale = context.l10n.isTagalog ? 'tl' : 'en';
      final list = await CareToolkitService.fetchQuestions(
        type: widget.checkType,
        locale: locale,
      );
      if (!mounted) return;
      setState(() => _questions = list);
    } catch (_) {
      if (mounted) setState(() => _questions = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  CareToolkitQuestion get _current => _questions[_index];

  bool get _currentAnswered {
    if (_questions.isEmpty) return false;
    final q = _current;
    if (q.answerType == 'time') return _times.containsKey(q.id);
    return _likert.containsKey(q.id);
  }

  String _title() {
    final l10n = context.l10n;
    return switch (widget.checkType) {
      'stress' => l10n.careStressCheck,
      'anxiety' => l10n.careAnxietyCheck,
      _ => l10n.careSleepQuality,
    };
  }

  String _intro() {
    final l10n = context.l10n;
    return switch (widget.checkType) {
      'stress' => l10n.careStressIntro,
      'anxiety' => l10n.careAnxietyIntro,
      _ => l10n.careSleepIntro,
    };
  }

  Future<void> _pickTime() async {
    final initial = _times[_current.id] ?? const TimeOfDay(hour: 22, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() => _times[_current.id] = picked);
  }

  Future<void> _submit() async {
    if (!_questions.every((q) {
      if (q.answerType == 'time') return _times.containsKey(q.id);
      return _likert.containsKey(q.id);
    })) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.careAnswerAll)),
      );
      return;
    }

    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      final answers = _questions.map((q) {
        if (q.answerType == 'time') {
          final t = _times[q.id]!;
          final hh = t.hour.toString().padLeft(2, '0');
          final mm = t.minute.toString().padLeft(2, '0');
          return {'question_id': q.id, 'value': '$hh:$mm'};
        }
        return {'question_id': q.id, 'value': _likert[q.id]};
      }).toList();
      final result = await CareCheckService.submit(
        checkType: widget.checkType,
        answers: answers,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.careCheckSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: CareColors.headingOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          _title(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: CareColors.headingOf(context),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CareColors.primary))
          : _questions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.careNoToolkitQuestions,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                )
              : !_started
                  ? CheckIntroView(
                      checkType: widget.checkType,
                      body: _intro(),
                      minutes: l10n.careCheckMinutes,
                      disclaimer: l10n.careCheckDisclaimer,
                      cta: l10n.careCheckStart,
                      onStart: () => setState(() => _started = true),
                    )
                  : CheckQuestionView(
                      question: _current,
                      index: _index,
                      total: _questions.length,
                      promptPrefix: widget.checkType == 'anxiety'
                          ? l10n.careAnxietyPrompt
                          : null,
                      selectedLikert: _likert[_current.id],
                      selectedTime: _times[_current.id],
                      onLikert: (value) => setState(() => _likert[_current.id] = value),
                      onPickTime: _pickTime,
                      onBack: _index == 0
                          ? null
                          : () => setState(() => _index -= 1),
                      onNext: !_currentAnswered
                          ? null
                          : () {
                              if (_index >= _questions.length - 1) {
                                _submit();
                              } else {
                                setState(() => _index += 1);
                              }
                            },
                      nextLabel: _index >= _questions.length - 1
                          ? l10n.careCheckSubmit
                          : l10n.careCheckNext,
                      backLabel: l10n.careCheckBack,
                      saving: _saving,
                    ),
    );
  }
}

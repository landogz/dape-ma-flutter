import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/care_toolkit_question.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../auth/login_screen.dart';
import '../care_colors.dart';
import '../care_toolkit_service.dart';
import 'care_check_service.dart';

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
        backgroundColor: CareColors.pageBgOf(context),
        foregroundColor: CareColors.headingOf(context),
        elevation: 0,
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
                  ? _IntroView(
                      body: _intro(),
                      minutes: l10n.careCheckMinutes,
                      disclaimer: l10n.careCheckDisclaimer,
                      cta: l10n.careCheckStart,
                      onStart: () => setState(() => _started = true),
                    )
                  : _QuestionView(
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

class _IntroView extends StatelessWidget {
  const _IntroView({
    required this.body,
    required this.minutes,
    required this.disclaimer,
    required this.cta,
    required this.onStart,
  });

  final String body;
  final String minutes;
  final String disclaimer;
  final String cta;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                minutes,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.4,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CareColors.mintOf(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            disclaimer,
            style: TextStyle(
              color: CareColors.textOf(context),
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onStart,
              borderRadius: BorderRadius.circular(999),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Center(
                  child: Text(
                    cta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selectedLikert,
    required this.selectedTime,
    required this.onLikert,
    required this.onPickTime,
    required this.onNext,
    required this.backLabel,
    required this.nextLabel,
    required this.saving,
    this.promptPrefix,
    this.onBack,
  });

  final CareToolkitQuestion question;
  final int index;
  final int total;
  final int? selectedLikert;
  final TimeOfDay? selectedTime;
  final ValueChanged<int> onLikert;
  final VoidCallback onPickTime;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String backLabel;
  final String nextLabel;
  final bool saving;
  final String? promptPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = (index + 1) / total;
    final options = question.options.isNotEmpty
        ? question.options
        : question.answerType == 'likert4'
            ? const [
                'Not at all',
                'Several days',
                'More than half the days',
                'Nearly every day',
              ]
            : [
                l10n.careScaleNever,
                l10n.careScaleAlmostNever,
                l10n.careScaleSometimes,
                l10n.careScaleFairlyOften,
                l10n.careScaleVeryOften,
              ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.careQuestionProgress(index + 1, total),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: CareColors.mintOf(context),
                  color: CareColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              if (promptPrefix != null && promptPrefix!.isNotEmpty) ...[
                Text(
                  promptPrefix!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                question.question,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: CareColors.headingOf(context),
                  fontSize: 20,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              if (question.answerType == 'time')
                _TimeAnswer(value: selectedTime, onPick: onPickTime)
              else
                ...List.generate(options.length, (i) {
                  final selected = selectedLikert == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: selected
                          ? CareColors.primary
                          : context.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onLikert(i);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selected
                                      ? Colors.white
                                      : CareColors.headingOf(context),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    options[i],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : CareColors.textOf(context),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                if (onBack != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving ? null : onBack,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: CareColors.headingOf(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(backLabel),
                    ),
                  ),
                if (onBack != null) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: onNext == null || saving
                          ? null
                          : AppColors.primaryGradient,
                      color: onNext == null || saving
                          ? context.mutedSurface
                          : null,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onNext == null || saving ? null : onNext,
                        borderRadius: BorderRadius.circular(999),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Center(
                            child: saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    nextLabel,
                                    style: TextStyle(
                                      color: onNext == null
                                          ? context.textSecondary
                                          : Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeAnswer extends StatelessWidget {
  const _TimeAnswer({required this.value, required this.onPick});

  final TimeOfDay? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final label = value?.format(context) ?? context.l10n.careInputTimeHint;
    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: CareColors.headingOf(context)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: CareColors.textOf(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/care_toolkit_question.dart';
import '../../auth/login_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../care_colors.dart';
import '../care_toolkit_service.dart';
import '../mood_checkin_service.dart';

/// Mockup-aligned toolkit check: intro + swipeable Care Bits question cards.
class CareBitsCheckScreen extends StatefulWidget {
  const CareBitsCheckScreen({
    super.key,
    required this.title,
    required this.source,
    required this.introBody,
    this.promptPrefix,
  });

  final String title;
  final String source;
  final String introBody;
  final String? promptPrefix;

  @override
  State<CareBitsCheckScreen> createState() => _CareBitsCheckScreenState();
}

class _CareBitsCheckScreenState extends State<CareBitsCheckScreen> {
  final _pageController = PageController(viewportFraction: 0.92);
  List<CareToolkitQuestion> _questions = [];
  final Map<int, int> _likertAnswers = {};
  final Map<int, TimeOfDay> _timeAnswers = {};
  bool _loading = true;
  bool _saving = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final locale = context.l10n.isTagalog ? 'tl' : 'en';
      final list = await CareToolkitService.fetchQuestions(
        type: widget.source,
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

  bool get _allAnswered {
    if (_questions.isEmpty) return false;
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.answerType == 'time') {
        if (!_timeAnswers.containsKey(i)) return false;
      } else if (!_likertAnswers.containsKey(i)) {
        return false;
      }
    }
    return true;
  }

  int get _score {
    if (_questions.isEmpty) return 0;
    var sum = 0;
    var max = 0;
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.answerType == 'time') {
        // Reward earlier-ish bedtimes loosely; still contribute to completion.
        final t = _timeAnswers[i];
        if (t == null) continue;
        final minutes = t.hour * 60 + t.minute;
        // Map 0–24h into 0–4 for scoring.
        sum += (minutes / 360).round().clamp(0, 4);
        max += 4;
      } else {
        final opts = q.options.isNotEmpty ? q.options.length : 5;
        final ans = _likertAnswers[i] ?? 0;
        sum += ans;
        max += (opts - 1).clamp(1, 10);
      }
    }
    if (max == 0) return 0;
    return ((sum / max) * 100).round().clamp(0, 100);
  }

  String get _moodFromScore {
    final s = _score;
    if (s >= 80) return 'great';
    if (s >= 60) return 'good';
    if (s >= 40) return 'meh';
    if (s >= 20) return 'difficult';
    return 'struggling';
  }

  Future<void> _submit() async {
    if (!_allAnswered) {
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
      await MoodCheckinService.create(
        mood: _moodFromScore,
        source: widget.source,
        score: _score,
        note: '${widget.title} score: $_score',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.careCheckSaved(_score))),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.careMoodSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(int index) async {
    final initial = _timeAnswers[index] ?? const TimeOfDay(hour: 22, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) return;
    setState(() => _timeAnswers[index] = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: CareColors.greenText,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CareColors.teal))
          : _questions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.careNoToolkitQuestions,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        children: [
                          _IntroCard(body: widget.introBody),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                l10n.careBitsTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: CareColors.greenText,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softBlue,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.swipe_rounded,
                                      size: 14,
                                      color: AppColors.mediumElectricBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.careBitsSwipeHint,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.mediumElectricBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.48,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _questions.length,
                              onPageChanged: (i) => setState(() => _page = i),
                              itemBuilder: (context, index) {
                                final q = _questions[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _QuestionCard(
                                    index: index,
                                    total: _questions.length,
                                    question: q,
                                    promptPrefix: widget.promptPrefix,
                                    selectedLikert: _likertAnswers[index],
                                    selectedTime: _timeAnswers[index],
                                    onLikert: (v) =>
                                        setState(() => _likertAnswers[index] = v),
                                    onPickTime: () => _pickTime(index),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_questions.length, (i) {
                              final active = i == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? CareColors.teal
                                      : CareColors.mint,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: CareColors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(l10n.careSaveCheck),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareColors.mintSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareColors.mint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.careRemember,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: CareColors.greenText,
                  ),
                ),
                const SizedBox(height: 6),
                _RememberRow(text: l10n.careRememberHonest),
                _RememberRow(text: l10n.careRememberNoWrong),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.emoji_emotions_rounded,
            size: 64,
            color: CareColors.teal,
          ),
        ],
      ),
    );
  }
}

class _RememberRow extends StatelessWidget {
  const _RememberRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: CareColors.teal),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.total,
    required this.question,
    required this.selectedLikert,
    required this.selectedTime,
    required this.onLikert,
    required this.onPickTime,
    this.promptPrefix,
  });

  final int index;
  final int total;
  final CareToolkitQuestion question;
  final int? selectedLikert;
  final TimeOfDay? selectedTime;
  final ValueChanged<int> onLikert;
  final VoidCallback onPickTime;
  final String? promptPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = (index + 1) / total;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.careQuestionProgress(index + 1, total),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: CareColors.mint,
                color: CareColors.tealDark,
              ),
            ),
            const SizedBox(height: 14),
            if (promptPrefix != null && promptPrefix!.isNotEmpty) ...[
              Text(
                promptPrefix!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: CareColors.greenText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.softBlue, CareColors.calmMint],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: CareColors.greenText,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: question.answerType == 'time'
                  ? _TimeAnswer(
                      value: selectedTime,
                      onPick: onPickTime,
                    )
                  : question.answerType == 'likert4'
                      ? _LikertButtons(
                          options: question.options,
                          selected: selectedLikert,
                          onSelect: onLikert,
                          stacked: true,
                        )
                      : _LikertList(
                          options: question.options.isNotEmpty
                              ? question.options
                              : [
                                  l10n.careScaleNever,
                                  l10n.careScaleAlmostNever,
                                  l10n.careScaleSometimes,
                                  l10n.careScaleFairlyOften,
                                  l10n.careScaleVeryOften,
                                ],
                          selected: selectedLikert,
                          onSelect: onLikert,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikertList extends StatelessWidget {
  const _LikertList({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              options[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected == i ? FontWeight.w800 : FontWeight.w600,
                color: selected == i
                    ? CareColors.tealDark
                    : CareColors.greenText.withValues(alpha: 0.75),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: List.generate(options.length, (i) {
            final active = selected == i;
            return InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? CareColors.teal : CareColors.mint,
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : CareColors.greenText,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _LikertButtons extends StatelessWidget {
  const _LikertButtons({
    required this.options,
    required this.selected,
    required this.onSelect,
    this.stacked = false,
  });

  final List<String> options;
  final int? selected;
  final ValueChanged<int> onSelect;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final opts = options.isNotEmpty
        ? options
        : const [
            'Not at all',
            'Several days',
            'More than half the days',
            'Nearly every day',
          ];

    return ListView.separated(
      itemCount: opts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final active = selected == i;
        return SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () => onSelect(i),
            style: FilledButton.styleFrom(
              backgroundColor: active ? CareColors.tealDark : CareColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              opts[i],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

class _TimeAnswer extends StatelessWidget {
  const _TimeAnswer({required this.value, required this.onPick});

  final TimeOfDay? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hour = value?.hourOfPeriod == 0 ? 12 : (value?.hourOfPeriod ?? 10);
    final minute = value?.minute ?? 25;
    final period = value == null
        ? 'PM'
        : (value!.period == DayPeriod.pm ? 'PM' : 'AM');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeBox(text: hour.toString().padLeft(2, '0')),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: CareColors.greenText,
                  ),
                ),
              ),
              _TimeBox(text: minute.toString().padLeft(2, '0')),
              const SizedBox(width: 10),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: CareColors.tealDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.careInputTimeHint,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CareColors.teal, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: CareColors.greenText,
        ),
      ),
    );
  }
}

class StressCheckScreen extends StatelessWidget {
  const StressCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CareBitsCheckScreen(
      title: l10n.careStressCheck,
      source: 'stress',
      introBody: l10n.careStressIntro,
    );
  }
}

class AnxietyCheckScreen extends StatelessWidget {
  const AnxietyCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CareBitsCheckScreen(
      title: l10n.careAnxietyCheck,
      source: 'anxiety',
      introBody: l10n.careAnxietyIntro,
      promptPrefix: l10n.careAnxietyPrompt,
    );
  }
}

class SleepQualityScreen extends StatelessWidget {
  const SleepQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CareBitsCheckScreen(
      title: l10n.careSleepQuality,
      source: 'sleep',
      introBody: l10n.careSleepIntro,
    );
  }
}

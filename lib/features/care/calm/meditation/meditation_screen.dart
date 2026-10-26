import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/accessibility/natural_tts/natural_tts_service.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_benefit_card.dart';
import '../widgets/calm_complete_page.dart';
import '../widgets/calm_info_sheet.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: CalmAppBar(
        title: l10n.careMeditationTitle,
        onInfo: () => showCalmInfoSheet(
          context,
          CalmInfoCopy(
            whyTitle: l10n.careWhyMeditation,
            whyBody: l10n.careWhyMeditationBody,
            howTitle: l10n.careHowToUse,
            howBody: l10n.careHowMeditationBody,
            tipTitle: l10n.careQuickTip,
            tipBody: l10n.careMeditationTip,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: CareColors.brandGradient,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.self_improvement_rounded, size: 96, color: Colors.white),
                    SizedBox(height: 8),
                    Icon(Icons.wb_sunny_rounded, size: 36, color: CareColors.accentGold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.careCalmMind,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: CareColors.headingOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.careCalmMindBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: CareColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 18),
            CalmBenefitCard(
              heading: l10n.careWhatYoullGet,
              items: [
                l10n.careBenefitReduceStress,
                l10n.careBenefitImproveFocus,
                l10n.careBenefitFeelCalm,
              ],
            ),
            const SizedBox(height: 24),
            CalmPrimaryButton(
              label: l10n.carePlayMeditation,
              onPressed: () {
                HapticFeedback.lightImpact();
                GuidedSessionLauncher.openMeditation(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum GuidedSessionMode { meditation, visualization }

class GuidedSessionLauncher {
  static void openMeditation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GuidedSessionPlayer(mode: GuidedSessionMode.meditation),
      ),
    );
  }

  static void openVisualization(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const GuidedSessionPlayer(mode: GuidedSessionMode.visualization),
      ),
    );
  }
}

class GuidedSessionPlayer extends StatefulWidget {
  const GuidedSessionPlayer({super.key, required this.mode});

  final GuidedSessionMode mode;

  @override
  State<GuidedSessionPlayer> createState() => _GuidedSessionPlayerState();
}

class _GuidedSessionPlayerState extends State<GuidedSessionPlayer> {
  final _tts = NaturalTtsService.instance;
  Timer? _ticker;
  int _seconds = 0;
  int _stepIndex = 0;
  bool _playing = false;
  bool _finished = false;
  static const _stepSeconds = 20;

  List<String> _stepsFor(AppStrings l10n) {
    if (widget.mode == GuidedSessionMode.meditation) {
      return [
        l10n.careMedStep1,
        l10n.careMedStep2,
        l10n.careMedStep3,
        l10n.careMedStep4,
      ];
    }
    return [
      l10n.careVizStep1,
      l10n.careVizStep2,
      l10n.careVizStep3,
      l10n.careVizStep4,
    ];
  }

  int get _totalSeconds => _stepSeconds * 4;

  @override
  void dispose() {
    _ticker?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakCurrent(List<String> steps) async {
    if (!_playing || !mounted) return;
    await _tts.speak(steps[_stepIndex]);
  }

  void _startTicker(List<String> steps) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_playing || !mounted || _finished) return;
      setState(() => _seconds++);
      final nextStep = (_seconds ~/ _stepSeconds).clamp(0, steps.length - 1);
      if (nextStep != _stepIndex) {
        _stepIndex = nextStep;
        await _speakCurrent(steps);
      }
      if (_seconds >= _totalSeconds) {
        await _finish();
      }
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    _playing = false;
    await _tts.stop();
    if (!mounted) return;
    final l10n = context.l10n;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CalmCompletePage(
          title: l10n.careWellDone,
          body: widget.mode == GuidedSessionMode.meditation
              ? l10n.careBreathingDoneBody
              : l10n.careAudioDoneBody,
          hint: l10n.careNoticeBody,
        ),
      ),
    );
  }

  Future<void> _toggle(List<String> steps) async {
    HapticFeedback.selectionClick();
    if (_playing) {
      await _tts.stop();
      _ticker?.cancel();
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    await _speakCurrent(steps);
    _startTicker(steps);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _stepsFor(l10n);
    final title = widget.mode == GuidedSessionMode.meditation
        ? l10n.careCalmMind
        : l10n.carePeacefulPlace;
    final progress = (_seconds / _totalSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(title: title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: CareColors.calmRing,
                color: CareColors.headingOf(context),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_stepIndex + 1} / ${steps.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: CareColors.mutedOf(context),
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                widget.mode == GuidedSessionMode.meditation
                    ? Icons.self_improvement_rounded
                    : Icons.spa_rounded,
                size: 88,
                color: CareColors.headingOf(context),
              ),
              const SizedBox(height: 24),
              Text(
                steps[_stepIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CareColors.headingOf(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Material(
                    color: CareColors.headingOf(context),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _toggle(steps),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CareColors.headingOf(context),
                        side: BorderSide(color: CareColors.cardBorderOf(context)),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        l10n.careEndSession,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

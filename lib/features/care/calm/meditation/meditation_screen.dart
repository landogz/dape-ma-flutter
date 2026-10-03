import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_benefit_card.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CalmAppBar(
        title: l10n.careMeditationTitle,
        onInfo: () => showCalmInfoDialog(
          context,
          title: l10n.careCalmInfoTitle,
          body: l10n.careCalmInfoBody,
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
                    Icon(Icons.self_improvement_rounded,
                        size: 96, color: Colors.white),
                    SizedBox(height: 8),
                    Icon(Icons.wb_sunny_rounded,
                        size: 36, color: CareColors.accentGold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.careCalmMind,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: CareColors.calmForest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.careCalmMindBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: CareColors.calmMuted,
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
        builder: (_) =>
            const GuidedSessionPlayer(mode: GuidedSessionMode.meditation),
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
  final _tts = FlutterTts();
  Timer? _ticker;
  int _seconds = 0;
  bool _playing = true;
  static const _totalSeconds = 90;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareAndSpeak());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_playing || !mounted) return;
      setState(() {
        _seconds++;
        if (_seconds >= _totalSeconds) {
          _playing = false;
          _tts.stop();
        }
      });
    });
  }

  Future<void> _prepareAndSpeak() async {
    if (!mounted) return;
    final l10n = context.l10n;
    final script = widget.mode == GuidedSessionMode.meditation
        ? '${l10n.careCalmMindBody} ${l10n.careStayCalmBreath}'
        : '${l10n.carePeacefulPlaceBody} ${l10n.careVizImagine}. ${l10n.careVizSenses}. ${l10n.careVizFeelRelaxed}.';
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    if (_playing) await _tts.speak(script);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.mode == GuidedSessionMode.meditation
        ? l10n.careCalmMind
        : l10n.carePeacefulPlace;
    final progress = (_seconds / _totalSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: CareColors.calmBg,
      appBar: CalmAppBar(title: title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                widget.mode == GuidedSessionMode.meditation
                    ? Icons.self_improvement_rounded
                    : Icons.spa_rounded,
                size: 96,
                color: CareColors.calmForest,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.careStayCalmBreath,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CareColors.calmForest,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 28),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: CareColors.calmRing,
                color: CareColors.calmForest,
              ),
              const Spacer(),
              Row(
                children: [
                  Material(
                    color: CareColors.calmForest,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        setState(() => _playing = !_playing);
                        if (_playing) {
                          await _prepareAndSpeak();
                        } else {
                          await _tts.stop();
                        }
                      },
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          _playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
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
                        foregroundColor: CareColors.calmForest,
                        side: const BorderSide(color: CareColors.calmRing),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_circle_visual.dart';

enum _BreathPhase { inhale, hold, exhale }

class GuidedBreathingScreen extends StatefulWidget {
  const GuidedBreathingScreen({super.key});

  @override
  State<GuidedBreathingScreen> createState() => _GuidedBreathingScreenState();
}

class _GuidedBreathingScreenState extends State<GuidedBreathingScreen> {
  static const _totalCycles = 5;
  static const _phaseSeconds = 4;

  Timer? _ticker;
  bool _running = true;
  bool _paused = false;
  _BreathPhase _phase = _BreathPhase.inhale;
  int _secondsLeft = _phaseSeconds;
  int _cycleIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running || _paused || !mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
          return;
        }
        _advancePhase();
      });
    });
  }

  void _advancePhase() {
    switch (_phase) {
      case _BreathPhase.inhale:
        _phase = _BreathPhase.hold;
        break;
      case _BreathPhase.hold:
        _phase = _BreathPhase.exhale;
        break;
      case _BreathPhase.exhale:
        _cycleIndex++;
        if (_cycleIndex >= _totalCycles) {
          _finish();
          return;
        }
        _phase = _BreathPhase.inhale;
        break;
    }
    _secondsLeft = _phaseSeconds;
  }

  void _finish() {
    _ticker?.cancel();
    _running = false;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.careSessionComplete)),
    );
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() => _paused = !_paused);
  }

  void _end() {
    HapticFeedback.lightImpact();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phaseLabel = switch (_phase) {
      _BreathPhase.inhale => l10n.careBreatheIn,
      _BreathPhase.hold => l10n.careBreatheHold,
      _BreathPhase.exhale => l10n.careBreatheOut,
    };
    final progress = ((_cycleIndex * 3) +
            (_phase == _BreathPhase.inhale
                ? 0
                : _phase == _BreathPhase.hold
                    ? 1
                    : 2) +
            (1 - _secondsLeft / _phaseSeconds)) /
        (_totalCycles * 3);

    return Scaffold(
      backgroundColor: CareColors.calmBg,
      appBar: CalmAppBar(
        title: l10n.careGuidedBreathing,
        onInfo: () => showCalmInfoDialog(
          context,
          title: l10n.careCalmInfoTitle,
          body: l10n.careCalmInfoBody,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Text(
                phaseLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CareColors.calmForest,
                ),
              ),
              const SizedBox(height: 16),
              CalmCircleVisual(
                progress: progress.clamp(0.0, 1.0),
                child: Text(
                  '$_secondsLeft',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.careStayCalmBreath,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CareColors.calmForest,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              _CycleDots(activeIndex: _cycleIndex, total: _totalCycles),
              const Spacer(flex: 2),
              Row(
                children: [
                  Material(
                    color: CareColors.calmForest,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _running ? _togglePause : null,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          _paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _end,
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

class _CycleDots extends StatelessWidget {
  const _CycleDots({required this.activeIndex, required this.total});

  final int activeIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= activeIndex
                    ? CareColors.calmForest
                    : CareColors.calmRing,
              ),
            ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= activeIndex
                  ? CareColors.calmForest
                  : CareColors.calmRing,
            ),
          ),
        ],
      ],
    );
  }
}

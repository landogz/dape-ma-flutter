import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_circle_visual.dart';
import '../widgets/calm_complete_page.dart';
import '../widgets/calm_info_sheet.dart';

enum _BreathPhase { inhale, hold, exhale }

class GuidedBreathingScreen extends StatefulWidget {
  const GuidedBreathingScreen({super.key});

  @override
  State<GuidedBreathingScreen> createState() => _GuidedBreathingScreenState();
}

class _GuidedBreathingScreenState extends State<GuidedBreathingScreen>
    with SingleTickerProviderStateMixin {
  static const _totalCycles = 4;
  static const _phaseSeconds = 4;

  late final AnimationController _pulse;
  late final Animation<double> _scale;
  Timer? _ticker;
  bool _running = false;
  _BreathPhase _phase = _BreathPhase.inhale;
  int _secondsLeft = _phaseSeconds;
  int _cycleIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _phaseSeconds),
    );
    _scale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _showInfo() {
    final l10n = context.l10n;
    showCalmInfoSheet(
      context,
      CalmInfoCopy(
        whyTitle: l10n.careWhyBreathing,
        whyBody: l10n.careWhyBreathingBody,
        howTitle: l10n.careHowToUse,
        howBody: l10n.careHowBreathingBody,
        tipTitle: l10n.careQuickTip,
        tipBody: l10n.careBreathingTip,
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running || !mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
          return;
        }
        _advancePhase();
      });
    });
  }

  void _syncPulse() {
    switch (_phase) {
      case _BreathPhase.inhale:
        _pulse.duration = const Duration(seconds: _phaseSeconds);
        _pulse.forward(from: 0);
        break;
      case _BreathPhase.hold:
        _pulse.stop();
        break;
      case _BreathPhase.exhale:
        _pulse.duration = const Duration(seconds: _phaseSeconds);
        _pulse.reverse(from: 1);
        break;
    }
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
    _syncPulse();
  }

  void _finish() {
    _ticker?.cancel();
    _running = false;
    _pulse.stop();
    if (!mounted) return;
    final l10n = context.l10n;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CalmCompletePage(
          title: l10n.careGreatJob,
          body: l10n.careBreathingDoneBody,
          hint: l10n.careNoticeBody,
        ),
      ),
    );
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _running = !_running;
      if (_running) {
        _syncPulse();
        _startTicker();
      } else {
        _ticker?.cancel();
        _pulse.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phaseLabel = switch (_phase) {
      _BreathPhase.inhale => l10n.careBreatheIn,
      _BreathPhase.hold => l10n.careBreatheHold,
      _BreathPhase.exhale => l10n.careBreatheOut,
    };
    final progress =
        ((_cycleIndex * 3) +
            (_phase == _BreathPhase.inhale
                ? 0
                : _phase == _BreathPhase.hold
                    ? 1
                    : 2) +
            (1 - _secondsLeft / _phaseSeconds)) /
        (_totalCycles * 3);

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(title: l10n.careGuidedBreathing, onInfo: _showInfo),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              const Spacer(),
              Text(
                _running ? phaseLabel : l10n.careBreatheReady,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CareColors.headingOf(context),
                ),
              ),
              const SizedBox(height: 16),
              ScaleTransition(
                scale: _running ? _scale : const AlwaysStoppedAnimation(1),
                child: CalmCircleVisual(
                  progress: progress.clamp(0.0, 1.0),
                  fillColor: CareColors.primary.withValues(alpha: 0.85),
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
              ),
              const SizedBox(height: 16),
              Text(
                l10n.careStayCalmBreath,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CareColors.headingOf(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              _CycleDots(activeIndex: _cycleIndex, total: _totalCycles),
              const Spacer(),
              Row(
                children: [
                  Material(
                    color: CareColors.headingOf(context),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _toggle,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
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
                color: i <= activeIndex ? CareColors.primary : CareColors.calmRing,
              ),
            ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= activeIndex ? CareColors.primary : CareColors.calmRing,
            ),
          ),
        ],
      ],
    );
  }
}

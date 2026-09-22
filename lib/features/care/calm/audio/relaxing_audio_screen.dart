import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_circle_visual.dart';

class RelaxingAudioScreen extends StatefulWidget {
  const RelaxingAudioScreen({super.key});

  @override
  State<RelaxingAudioScreen> createState() => _RelaxingAudioScreenState();
}

class _RelaxingAudioScreenState extends State<RelaxingAudioScreen> {
  static const _duration = Duration(minutes: 3);

  Timer? _ticker;
  bool _playing = true;
  Duration _position = Duration.zero;

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
      if (!_playing || !mounted) return;
      setState(() {
        if (_position >= _duration) {
          _playing = false;
          return;
        }
        _position += const Duration(seconds: 1);
      });
    });
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _playing = !_playing);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress =
        (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: CareColors.calmBg,
      appBar: CalmAppBar(
        title: l10n.careRelaxingAudio,
        onInfo: () => showCalmInfoDialog(
          context,
          title: l10n.careCalmInfoTitle,
          body: l10n.careCalmInfoBody,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            children: [
              Text(
                l10n.careListen,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CareColors.calmForest,
                ),
              ),
              const Spacer(),
              CalmCircleVisual(
                progress: progress,
                child: const Icon(
                  Icons.music_note_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.careStayCalmMusic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CareColors.calmForest,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: CareColors.calmForest,
                  inactiveTrackColor: CareColors.calmRing,
                  thumbColor: CareColors.calmForest,
                  trackHeight: 3,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: progress,
                  onChanged: (v) {
                    setState(() {
                      _position = Duration(
                        milliseconds:
                            (_duration.inMilliseconds * v).round(),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Material(
                color: CareColors.calmMintBtn,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: CareColors.calmForest.withValues(alpha: 0.25),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggle,
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Icon(
                      _playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
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

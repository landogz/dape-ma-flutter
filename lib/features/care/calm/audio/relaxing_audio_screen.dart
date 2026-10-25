import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_circle_visual.dart';
import '../widgets/calm_complete_page.dart';
import '../widgets/calm_info_sheet.dart';

class RelaxingAudioScreen extends StatefulWidget {
  const RelaxingAudioScreen({super.key});

  @override
  State<RelaxingAudioScreen> createState() => _RelaxingAudioScreenState();
}

class _RelaxingAudioScreenState extends State<RelaxingAudioScreen> {
  static const _duration = Duration(minutes: 2);
  static const _asset = 'care/calm/relaxing_tone.wav';

  final AudioPlayer _player = AudioPlayer();
  Timer? _ticker;
  bool _playing = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(0.55);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _showInfo() {
    final l10n = context.l10n;
    showCalmInfoSheet(
      context,
      CalmInfoCopy(
        whyTitle: l10n.careWhyMusic,
        whyBody: l10n.careWhyMusicBody,
        howTitle: l10n.careHowToUse,
        howBody: l10n.careHowMusicBody,
        tipTitle: l10n.careQuickTip,
        tipBody: l10n.careMusicTip,
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_playing || !mounted) return;
      setState(() {
        _position += const Duration(seconds: 1);
        if (_position >= _duration) {
          _finish();
        }
      });
    });
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _playing = false;
    await _player.stop();
    if (!mounted) return;
    final l10n = context.l10n;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CalmCompletePage(
          title: l10n.careWellDone,
          body: l10n.careAudioDoneBody,
          hint: l10n.careNoticeBody,
        ),
      ),
    );
  }

  Future<void> _toggle() async {
    HapticFeedback.selectionClick();
    if (_playing) {
      await _player.pause();
      _ticker?.cancel();
      setState(() => _playing = false);
      return;
    }
    await _player.play(AssetSource(_asset));
    _startTicker();
    setState(() => _playing = true);
  }

  Future<void> _seek(double value) async {
    final next = Duration(milliseconds: (_duration.inMilliseconds * value).round());
    setState(() => _position = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress =
        (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    final remaining = _duration - _position;
    final remainingLabel =
        '${remaining.inMinutes.remainder(60).toString().padLeft(1, '0')}:${(remaining.inSeconds.remainder(60)).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(title: l10n.careRelaxingAudio, onInfo: _showInfo),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            children: [
              Text(
                l10n.careListen,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CareColors.headingOf(context),
                ),
              ),
              const Spacer(),
              CalmCircleVisual(
                progress: progress,
                fillColor: CareColors.primary.withValues(alpha: 0.88),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.careStayCalmMusic,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CareColors.headingOf(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                remainingLabel,
                style: TextStyle(
                  color: CareColors.mutedOf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.mediumElectricBlue,
                  inactiveTrackColor: CareColors.calmRing,
                  thumbColor: AppColors.mediumElectricBlue,
                  trackHeight: 3,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: progress,
                  onChanged: _seek,
                ),
              ),
              const SizedBox(height: 20),
              Material(
                color: AppColors.mediumElectricBlue,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: AppColors.mediumElectricBlue.withValues(alpha: 0.25),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggle,
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
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

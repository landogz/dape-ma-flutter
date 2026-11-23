import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_circle_visual.dart';
import '../widgets/calm_complete_page.dart';
import '../widgets/calm_info_sheet.dart';
import 'relaxing_music_repository.dart';

class RelaxingAudioScreen extends StatefulWidget {
  const RelaxingAudioScreen({super.key});

  @override
  State<RelaxingAudioScreen> createState() => _RelaxingAudioScreenState();
}

class _RelaxingAudioScreenState extends State<RelaxingAudioScreen> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<void>? _completeSub;

  List<PlayableRelaxingTrack> _tracks = const [];
  PlayableRelaxingTrack? _selected;
  bool _loading = true;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setVolume(0.7);
    unawaited(_configureAudioSession());
    _positionSub = _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
    _durationSub = _player.onDurationChanged.listen((dur) {
      if (!mounted || dur <= Duration.zero) return;
      setState(() => _duration = dur);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      _finish();
    });
    _loadTracks();
  }

  Future<void> _configureAudioSession() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
    } catch (_) {
      // Ignore if the platform rejects the session config.
    }
  }

  Future<void> _loadTracks() async {
    setState(() => _loading = true);
    final tracks = await RelaxingMusicRepository.instance.fetchPlayable();
    if (!mounted) return;
    setState(() {
      _tracks = tracks;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _completeSub?.cancel();
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

  Future<void> _finish() async {
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
          tool: 'audio',
        ),
      ),
    );
  }

  Future<void> _selectTrack(PlayableRelaxingTrack track) async {
    HapticFeedback.selectionClick();
    if (_selected?.id == track.id) return;
    await _player.stop();
    setState(() {
      _selected = track;
      _playing = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  Future<void> _toggle() async {
    final track = _selected;
    if (track == null) return;
    HapticFeedback.selectionClick();
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }
    if (_position > Duration.zero &&
        _duration > Duration.zero &&
        _position < _duration) {
      await _player.resume();
      setState(() => _playing = true);
      return;
    }

    final started = await _startPlayback(track);
    if (!mounted) return;
    if (started) {
      setState(() => _playing = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not play this track.')),
    );
  }

  /// Seeded / known tracks play from bundled assets (reliable on iOS).
  /// New CMS uploads download into memory and play via [BytesSource].
  Future<bool> _startPlayback(PlayableRelaxingTrack track) async {
    await _player.stop();

    if (track.asset != null && track.asset!.isNotEmpty) {
      try {
        await _player.play(AssetSource(track.asset!));
        return true;
      } catch (error) {
        debugPrint('[RelaxingAudio] asset play failed: $error');
      }
    }

    if (track.isRemote) {
      try {
        final bytes = await _downloadBytes(track.audioUrl!);
        await _player.play(BytesSource(bytes, mimeType: _mimeForUrl(track.audioUrl!)));
        return true;
      } catch (error) {
        debugPrint('[RelaxingAudio] remote play failed: $error');
      }
    }

    return false;
  }

  Future<Uint8List> _downloadBytes(String url) async {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (code) => code != null && code >= 200 && code < 400,
      ),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('Empty audio download');
    }
    return Uint8List.fromList(data);
  }

  String _mimeForUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.mp3')) return 'audio/mpeg';
    if (path.endsWith('.wav')) return 'audio/wav';
    if (path.endsWith('.aac')) return 'audio/aac';
    if (path.endsWith('.ogg')) return 'audio/ogg';
    return 'audio/mp4';
  }

  Future<void> _seek(double value) async {
    if (_duration <= Duration.zero) return;
    final next = Duration(
      milliseconds: (_duration.inMilliseconds * value).round(),
    );
    await _player.seek(next);
    setState(() => _position = next);
  }

  Future<void> _backToList() async {
    HapticFeedback.selectionClick();
    await _player.stop();
    setState(() {
      _selected = null;
      _playing = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(
        title: l10n.careRelaxingAudio,
        onInfo: _showInfo,
        onBack: selected == null ? null : _backToList,
      ),
      body: SafeArea(
        child: selected == null ? _buildTrackList(context) : _buildPlayer(context),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context) {
    final l10n = context.l10n;
    final heading = CareColors.headingOf(context);
    final muted = CareColors.mutedOf(context);

    if (_loading && _tracks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text(
          l10n.careChooseTrack,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: heading,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.careChooseTrackBody,
          style: TextStyle(
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        const SizedBox(height: 16),
        if (_tracks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              l10n.careChooseTrackBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontWeight: FontWeight.w500),
            ),
          )
        else
          for (var i = 0; i < _tracks.length; i++) ...[
            _TrackTile(
              index: i + 1,
              title: _tracks[i].titleOf(l10n),
              onTap: () => _selectTrack(_tracks[i]),
            ),
          ],
      ],
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final l10n = context.l10n;
    final track = _selected!;
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    final remaining = _duration > _position ? _duration - _position : Duration.zero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        children: [
          Text(
            track.titleOf(l10n),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CareColors.headingOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.careListen,
            style: TextStyle(
              color: CareColors.mutedOf(context),
              fontWeight: FontWeight.w600,
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
            _duration > Duration.zero ? _format(remaining) : '--:--',
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
              onChanged: _duration > Duration.zero ? _seek : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(_position),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CareColors.mutedOf(context),
                ),
              ),
              Text(
                _duration > Duration.zero ? _format(_duration) : '--:--',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CareColors.mutedOf(context),
                ),
              ),
            ],
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
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.index,
    required this.title,
    required this.onTap,
  });

  final int index;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final heading = CareColors.headingOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: CareColors.cardFillOf(context),
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        shadowColor: AppColors.mediumElectricBlue.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mediumElectricBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.mediumElectricBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: heading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.careRelaxingTrackSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CareColors.mutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_filled_rounded,
                  color: AppColors.mediumElectricBlue,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

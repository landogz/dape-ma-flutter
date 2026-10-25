import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_complete_page.dart';
import '../widgets/calm_info_sheet.dart';
import '../../../../core/theme/app_theme_colors.dart';

class StretchBreaksScreen extends StatefulWidget {
  const StretchBreaksScreen({super.key});

  @override
  State<StretchBreaksScreen> createState() => _StretchBreaksScreenState();
}

class _StretchBreaksScreenState extends State<StretchBreaksScreen> {
  static const _reminderKey = 'calm_stretch_reminder_enabled';
  bool _reminderOn = false;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _reminderOn = prefs.getBool(_reminderKey) ?? false);
  }

  Future<void> _setReminder(bool value) async {
    setState(() => _reminderOn = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, value);
  }

  void _openStretch({
    required String title,
    required String body,
    required IconData icon,
  }) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _StretchSessionScreen(
          title: title,
          body: body,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: CalmAppBar(
        title: '',
        onInfo: () => showCalmInfoSheet(
          context,
          CalmInfoCopy(
            whyTitle: l10n.careWhyMeditation,
            whyBody: l10n.careStretchSessionHint,
            howTitle: l10n.careHowToUse,
            howBody: l10n.careCalmStudentIntro,
            tipTitle: l10n.careQuickTip,
            tipBody: l10n.careStretchHold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            const Icon(
              Icons.hourglass_bottom_rounded,
              size: 72,
              color: CareColors.accentGold,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.careStretchBreaks,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: CareColors.headingOf(context),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.careChooseYourBreak,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CareColors.headingOf(context),
              ),
            ),
            const SizedBox(height: 12),
            _StretchCard(
              title: l10n.careQuickStretch,
              subtitle: l10n.careQuickStretchBody,
              icon: Icons.alarm_rounded,
              onTap: () => _openStretch(
                title: l10n.careQuickStretch,
                body: l10n.careQuickStretchBody,
                icon: Icons.alarm_rounded,
              ),
            ),
            _StretchCard(
              title: l10n.careDeskStretch,
              subtitle: l10n.careDeskStretchBody,
              icon: Icons.desk_rounded,
              onTap: () => _openStretch(
                title: l10n.careDeskStretch,
                body: l10n.careDeskStretchBody,
                icon: Icons.desk_rounded,
              ),
            ),
            _StretchCard(
              title: l10n.careFullBodyStretch,
              subtitle: l10n.careFullBodyStretchBody,
              icon: Icons.accessibility_new_rounded,
              onTap: () => _openStretch(
                title: l10n.careFullBodyStretch,
                body: l10n.careFullBodyStretchBody,
                icon: Icons.accessibility_new_rounded,
              ),
            ),
            _StretchCard(
              title: l10n.careMorningEnergizer,
              subtitle: l10n.careMorningEnergizerBody,
              icon: Icons.wb_sunny_rounded,
              onTap: () => _openStretch(
                title: l10n.careMorningEnergizer,
                body: l10n.careMorningEnergizerBody,
                icon: Icons.wb_sunny_rounded,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.careSetTodaysReminder,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CareColors.headingOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: CareColors.cardBorderOf(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CareColors.calmCardOf(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm_rounded,
                      color: CareColors.headingOf(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.careStretchReminderTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: CareColors.headingOf(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.careStretchReminderBody,
                          style: TextStyle(
                            color: CareColors.mutedOf(context),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _reminderOn,
                    activeThumbColor: AppColors.mediumElectricBlue,
                    onChanged: _setReminder,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StretchCard extends StatelessWidget {
  const _StretchCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: CareColors.calmCardOf(context),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: CareColors.headingOf(context)),
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
                          color: CareColors.headingOf(context),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: CareColors.mutedOf(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: CareColors.headingOf(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StretchSessionScreen extends StatefulWidget {
  const _StretchSessionScreen({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  State<_StretchSessionScreen> createState() => _StretchSessionScreenState();
}

class _StretchSessionScreenState extends State<_StretchSessionScreen> {
  static const _holdSeconds = 20;
  Timer? _ticker;
  bool _running = false;
  bool _finished = false;
  int _step = 0;
  int _secondsLeft = _holdSeconds;

  List<String> _cues(AppStrings l10n) => [
        widget.body,
        l10n.careStretchNeck,
        l10n.careStretchShoulders,
        l10n.careStretchReach,
      ];

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _running = !_running);
    if (_running) {
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_running || !mounted || _finished) return;
        setState(() {
          if (_secondsLeft > 1) {
            _secondsLeft--;
            return;
          }
          final cues = _cues(context.l10n);
          if (_step >= cues.length - 1) {
            _complete();
            return;
          }
          _step++;
          _secondsLeft = _holdSeconds;
        });
      });
    } else {
      _ticker?.cancel();
    }
  }

  void _complete() {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    _running = false;
    final l10n = context.l10n;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CalmCompletePage(
          title: l10n.careWellDone,
          body: l10n.careSessionComplete,
          hint: l10n.careNoticeBody,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cues = _cues(l10n);
    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(title: widget.title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '${_step + 1} / ${cues.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: CareColors.mutedOf(context),
                ),
              ),
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: CareColors.calmCardOf(context),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$_secondsLeft',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: CareColors.headingOf(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Icon(widget.icon, size: 40, color: CareColors.headingOf(context)),
              const SizedBox(height: 16),
              Text(
                l10n.careStretchHold,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: CareColors.headingOf(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cues[_step],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: CareColors.headingOf(context),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Material(
                    color: AppColors.mediumElectricBlue,
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

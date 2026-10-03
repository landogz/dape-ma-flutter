import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/mood_checkin.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../diary/widgets/journal_wizard/journal_wizard_sheet.dart';
import 'care_colors.dart';
import 'care_constants.dart';
import 'mood_checkin_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<MoodCheckin> _items = [];
  bool _loading = true;
  bool _saving = false;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await MoodCheckinService.fetchList(perPage: 100);
      if (!mounted) return;
      setState(() => _items = list);
    } catch (_) {
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<DateTime, String> get _moodByDay {
    final map = <DateTime, String>{};
    for (final item in _items) {
      final raw = item.createdAt;
      if (raw == null) continue;
      final dt = DateTime.tryParse(raw)?.toLocal();
      if (dt == null) continue;
      final key = DateTime(dt.year, dt.month, dt.day);
      // Keep latest mood of the day.
      map[key] = item.mood;
    }
    return map;
  }

  Map<String, int> get _monthCounts {
    final counts = <String, int>{
      for (final m in CareConstants.moods) m.key: 0,
    };
    for (final entry in _moodByDay.entries) {
      if (entry.key.year == _visibleMonth.year &&
          entry.key.month == _visibleMonth.month) {
        counts[entry.value] = (counts[entry.value] ?? 0) + 1;
      }
    }
    return counts;
  }

  String _insightText() {
    final l10n = context.l10n;
    final counts = _monthCounts;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return l10n.careMoodInsightSteady;
    final low = (counts['struggling'] ?? 0) + (counts['difficult'] ?? 0);
    final high = (counts['good'] ?? 0) + (counts['great'] ?? 0);
    if (low / total >= 0.4) return l10n.careMoodInsightLow;
    if (high / total >= 0.5) return l10n.careMoodInsightGreat;
    return l10n.careMoodInsightSteady;
  }

  Future<void> _checkInToday() async {
    var token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true) return;
    }
    if (!mounted) return;

    final mood = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isTl = ctx.l10n.isTagalog;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctx.l10n.careHowFeeling,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: CareColors.greenText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: CareConstants.moods.map((m) {
                    return Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx, m.key),
                        child: Column(
                          children: [
                            Text(m.emoji, style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 4),
                            Text(
                              isTl ? m.labelTl : m.labelEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mood == null || !mounted) return;

    setState(() => _saving = true);
    try {
      await MoodCheckinService.create(mood: mood, source: 'mood_tracker');
      if (!mounted) return;
      await showJournalWizard(
        context,
        initialSky: CareConstants.skyForCareMood(mood),
        initialFeelings: CareConstants.feelingsForCareMood(mood),
      );
      if (!mounted) return;
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.careMoodSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isTl = l10n.isTagalog;
    final counts = _monthCounts;
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: CareColors.greenText,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.careMoodTracker,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CareColors.teal))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _CalendarCard(
                  month: _visibleMonth,
                  moodByDay: _moodByDay,
                  selectedDay: _selectedDay,
                  onPrev: () => _shiftMonth(-1),
                  onNext: () => _shiftMonth(1),
                  onSelect: (d) => setState(() => _selectedDay = d),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      l10n.careMoodOverview,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: CareColors.greenText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.careThisMonth,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CareColors.teal.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: _MoodDonutPainter(counts: counts),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _LegendRow(
                            color: AppColors.fireEngineRed,
                            label: l10n.careMoodVeryBad,
                            pct: total == 0
                                ? 0
                                : ((counts['struggling'] ?? 0) / total * 100)
                                    .round(),
                          ),
                          _LegendRow(
                            color: AppColors.fireEngineRed,
                            label: l10n.careMoodBad,
                            pct: total == 0
                                ? 0
                                : ((counts['difficult'] ?? 0) / total * 100)
                                    .round(),
                          ),
                          _LegendRow(
                            color: AppColors.brightGold,
                            label: l10n.careMoodOkay,
                            pct: total == 0
                                ? 0
                                : ((counts['meh'] ?? 0) / total * 100).round(),
                          ),
                          _LegendRow(
                            color: AppColors.mediumElectricBlue,
                            label: isTl
                                ? CareConstants.moods
                                    .firstWhere((m) => m.key == 'good')
                                    .labelTl
                                : CareConstants.moods
                                    .firstWhere((m) => m.key == 'good')
                                    .labelEn,
                            pct: total == 0
                                ? 0
                                : ((counts['good'] ?? 0) / total * 100).round(),
                          ),
                          _LegendRow(
                            color: AppColors.nileBlue,
                            label: isTl
                                ? CareConstants.moods
                                    .firstWhere((m) => m.key == 'great')
                                    .labelTl
                                : CareConstants.moods
                                    .firstWhere((m) => m.key == 'great')
                                    .labelEn,
                            pct: total == 0
                                ? 0
                                : ((counts['great'] ?? 0) / total * 100).round(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CareColors.mintSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CareColors.mint),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_rounded, color: CareColors.teal, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _insightText(),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _checkInToday,
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
                  : Text(
                      l10n.careCheckInTodayCta,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.moodByDay,
    required this.selectedDay,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  final DateTime month;
  final Map<DateTime, String> moodByDay;
  final DateTime? selectedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Sunday-first
    final monthLabel = DateFormat('MMM').format(month);
    final yearLabel = '${month.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CareColors.mint),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left_rounded),
                color: CareColors.greenText,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Chip(label: monthLabel),
                    const SizedBox(width: 8),
                    _Chip(label: yearLabel),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
                color: CareColors.greenText,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CareColors.greenText,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }
              final day = index - startWeekday + 1;
              final date = DateTime(month.year, month.month, day);
              final mood = moodByDay[date];
              final selected = selectedDay != null &&
                  selectedDay!.year == date.year &&
                  selectedDay!.month == date.month &&
                  selectedDay!.day == date.day;

              return InkWell(
                onTap: () => onSelect(date),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? CareColors.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: selected ? Colors.white : CareColors.greenText,
                          ),
                        ),
                      ),
                      if (mood != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            CareConstants.moods
                                .firstWhere(
                                  (m) => m.key == mood,
                                  orElse: () => CareConstants.moods[2],
                                )
                                .emoji,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CareColors.mintSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CareColors.mint),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: CareColors.greenText,
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.pct,
  });

  final Color color;
  final String label;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CareColors.greenText,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodDonutPainter extends CustomPainter {
  _MoodDonutPainter({required this.counts});

  final Map<String, int> counts;

  static const _colors = {
    'struggling': AppColors.fireEngineRed,
    'difficult': AppColors.fireEngineRed,
    'meh': AppColors.brightGold,
    'good': AppColors.mediumElectricBlue,
    'great': AppColors.nileBlue,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      stroke.color = CareColors.mint;
      canvas.drawArc(rect, 0, math.pi * 2, false, stroke);
      return;
    }

    var start = -math.pi / 2;
    for (final key in ['struggling', 'difficult', 'meh', 'good', 'great']) {
      final value = counts[key] ?? 0;
      if (value <= 0) continue;
      final sweep = (value / total) * math.pi * 2;
      stroke.color = _colors[key] ?? CareColors.teal;
      canvas.drawArc(rect, start, sweep, false, stroke);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MoodDonutPainter oldDelegate) =>
      oldDelegate.counts != counts;
}

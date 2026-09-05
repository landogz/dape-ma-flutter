import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import 'bible_home_screen.dart';
import 'daily_verse_service.dart';

class DailyVerseWelcomeScreen extends StatefulWidget {
  const DailyVerseWelcomeScreen({
    super.key,
    required this.initialPosts,
  });

  final List<Post> initialPosts;

  @override
  State<DailyVerseWelcomeScreen> createState() => _DailyVerseWelcomeScreenState();
}

class _DailyVerseWelcomeScreenState extends State<DailyVerseWelcomeScreen> {
  bool _loading = true;
  String _brand = 'Kid Listo Says';
  String _brandTagline = '';
  String _reference = '';
  String _verseText = '';
  String _kidMessage = '';
  String _translation = '';
  int _dayOfYear = 0;
  int _totalDays = 365;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVerse());
  }

  Future<void> _loadVerse() async {
    try {
      final locale = LocaleScope.of(context).locale.code;
      final verse = await DailyVerseService.fetchToday(locale: locale);
      if (!mounted) return;
      setState(() {
        _brand = verse?.brand ?? 'Kid Listo Says';
        _brandTagline = verse?.brandTagline ?? '';
        _reference = verse?.reference ?? '';
        _verseText = verse?.verseText ?? '';
        _kidMessage = verse?.kidListoMessage ?? '';
        _translation = verse?.translation ?? '';
        _dayOfYear = verse?.dayOfYear ?? 0;
        _totalDays = verse?.totalDays ?? 365;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(initialPosts: widget.initialPosts),
      ),
    );
  }

  void _openBible() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BibleHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = DateFormat.yMMMMEEEEd().format(DateTime.now());

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Image.asset('assets/ddb.png', width: 44, height: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _brand.isNotEmpty ? _brand : l10n.kidListoSaysTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            today,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _openHome,
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (_dayOfYear > 0) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.kidListoDayLabel(_dayOfYear, _totalDays),
                        style: const TextStyle(
                          color: AppColors.secondaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 140,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.kidListoSaysTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                            if (_brandTagline.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _brandTagline,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Text(
                              _kidMessage.isNotEmpty
                                  ? _kidMessage
                                  : l10n.dailyVerseFallback,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    height: 1.45,
                                    color: AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.todaysScripture,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _verseText.isNotEmpty
                                        ? _verseText
                                        : l10n.dailyVerseFallback,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          height: 1.5,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _reference.isNotEmpty
                                        ? _reference
                                        : l10n.dailyVerseReferenceFallback,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  if (_translation.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _translation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                const Spacer(),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: AppColors.secondaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      l10n.continueToApp,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _openBible,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: Text(l10n.openKidListoBible),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

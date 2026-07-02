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
  String _reference = '';
  String _verseText = '';
  String _translation = '';

  @override
  void initState() {
    super.initState();
    _loadVerse();
  }

  Future<void> _loadVerse() async {
    try {
      final verse = await DailyVerseService.fetchToday();
      if (!mounted) return;
      setState(() {
        _reference = verse?.reference ?? '';
        _verseText = verse?.verseText ?? '';
        _translation = verse?.translation ?? '';
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
                            l10n.dailyVerseTitle,
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
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.primaryBlue.withValues(alpha: 0.85),
                              size: 32,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _verseText.isNotEmpty
                                  ? _verseText
                                  : l10n.dailyVerseFallback,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    height: 1.5,
                                    color: AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 16),
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
                    label: Text(l10n.openBible),
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

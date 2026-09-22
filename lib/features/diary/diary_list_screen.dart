import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/diary_entry.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../auth/login_screen.dart';
import 'diary_service.dart';
import 'widgets/journal_wizard/journal_constants.dart';
import 'widgets/journal_wizard/journal_prompts.dart';
import 'widgets/journal_wizard/journal_wizard_sheet.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<DiaryEntry> _entries = [];
  DiaryEntry? _todayEntry;
  bool _loading = false;
  bool _isLoggedIn = false;
  String? _firstName;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await AuthService.getToken();
    final loggedIn = token != null && token.isNotEmpty;
    if (!mounted) return;
    setState(() => _isLoggedIn = loggedIn);
    if (loggedIn) {
      await Future.wait([_loadEntries(), _loadFirstName()]);
    }
  }

  Future<void> _loadFirstName() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.me,
      );
      final data = res.data ?? <String, dynamic>{};
      final user = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final name = (user['name'] as String?)?.trim() ?? '';
      if (!mounted || name.isEmpty) return;
      setState(() => _firstName = name.split(RegExp(r'\s+')).first);
    } catch (_) {}
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DiaryService.fetchEntries(),
        DiaryService.fetchToday(),
      ]);
      if (!mounted) return;
      setState(() {
        _entries = results[0] as List<DiaryEntry>;
        _todayEntry = results[1] as DiaryEntry?;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _entries = [];
          _todayEntry = null;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requireLogin() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (loggedIn == true && mounted) {
      setState(() => _isLoggedIn = true);
      await Future.wait([_loadEntries(), _loadFirstName()]);
    }
  }

  Future<void> _openWizard({DiaryEntry? entry}) async {
    if (!_isLoggedIn) {
      await _requireLogin();
      return;
    }

    final saved = await showJournalWizard(
      context,
      existing: entry,
      firstName: _firstName,
    );

    if (saved == true && mounted) {
      await _loadEntries();
    }
  }

  Future<void> _writeToday() async {
    if (!_isLoggedIn) {
      await _requireLogin();
      return;
    }

    try {
      final today = await DiaryService.fetchToday();
      if (!mounted) return;
      await _openWizard(entry: today);
    } catch (_) {
      if (!mounted) return;
      await _openWizard();
    }
  }

  String _formatHeaderDate(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date).toUpperCase();
  }

  String _formatEntryDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('MMM d, yyyy').format(parsed);
  }

  String _skyDisplayLabel(String? skyKey) {
    final opt = JournalConstants.skyByKey(skyKey);
    if (opt == null) return '';
    return context.l10n.isTagalog ? opt.labelTl : opt.labelEn;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final skyLabel = _skyDisplayLabel(_todayEntry?.sky);
    final prompt = JournalPrompts.forDate(now, isTagalog: l10n.isTagalog);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      floatingActionButton: _isLoggedIn
          ? Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: FloatingActionButton(
                onPressed: _writeToday,
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.secondaryBlue,
                elevation: 4,
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
      body: !_isLoggedIn
          ? _LoginRequired(onLogin: _requireLogin)
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 22),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.secondaryBlue,
                        AppColors.primaryBlue,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.of(context).maybePop(),
                              child: const SizedBox(
                                width: 44,
                                height: 44,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatHeaderDate(now),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.diaryTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        skyLabel.isEmpty
                            ? l10n.journalDailyReflection
                            : l10n.journalWritingThroughSky(skyLabel),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading && _entries.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          color: AppColors.primaryBlue,
                          onRefresh: _loadEntries,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            children: [
                              _DailyReflectionCard(
                                prompt: prompt,
                                onStart: _writeToday,
                              ),
                              const SizedBox(height: 22),
                              Text(
                                l10n.journalYourEntries,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondaryBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_entries.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.book_outlined,
                                        size: 56,
                                        color: context.textSecondary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.diaryEmpty,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ..._entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _EntryCard(
                                      entry: entry,
                                      dateLabel: _formatEntryDate(entry.entryDate),
                                      skyLabel: _skyDisplayLabel(entry.sky),
                                      onTap: () => _openWizard(entry: entry),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 56, color: context.textSecondary),
            const SizedBox(height: 16),
            Text(
              l10n.diaryLoginRequired,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
              child: Text(l10n.login),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyReflectionCard extends StatelessWidget {
  const _DailyReflectionCard({
    required this.prompt,
    required this.onStart,
  });

  final String prompt;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppColors.accentYellow,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.journalDailyReflection.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.secondaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prompt,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.secondaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.writeToday,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.dateLabel,
    required this.skyLabel,
    required this.onTap,
  });

  final DiaryEntry entry;
  final String dateLabel;
  final String skyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = JournalConstants.accentForSky(entry.sky);
    final preview = entry.hasNotes ? entry.notesPreview : l10n.journalNoWrittenNotes;
    final feelings = entry.feelings;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondaryBlue,
                              ),
                            ),
                          ),
                          if (skyLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                skyLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryBlue
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontStyle:
                              entry.hasNotes ? FontStyle.normal : FontStyle.italic,
                          color: entry.hasNotes
                              ? AppColors.textPrimaryLight
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (feelings.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: feelings.take(4).map((feeling) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                feeling,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
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

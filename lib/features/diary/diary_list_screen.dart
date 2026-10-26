import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/diary_entry.dart';
import '../../core/network/endpoints.dart';
import '../../core/options/app_option_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/utils/api_url.dart';
import '../auth/login_screen.dart';
import 'diary_service.dart';
import 'widgets/journal_filter/journal_entry_filters.dart';
import 'widgets/journal_filter/journal_filter_bar.dart';
import 'widgets/journal_filter/journal_filter_sheet.dart';
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
  List<String> _customFeelings = [];
  JournalEntryFilters _filters = const JournalEntryFilters();

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
      await Future.wait([
        _loadEntries(),
        _loadFirstName(),
        AppOptionCatalog.prefetch(),
      ]);
      if (mounted) setState(() {});
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
      final custom = (user['journal_custom_feelings'] as List?)
              ?.map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList() ??
          const <String>[];
      if (!mounted) return;
      setState(() {
        if (name.isNotEmpty) {
          _firstName = name.split(RegExp(r'\s+')).first;
        }
        _customFeelings = custom;
      });
    } catch (_) {}
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DiaryService.fetchEntries(query: _filters.toQuery()),
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

  Future<void> _setPeriod(String period) async {
    if (_filters.period == period) return;
    setState(() => _filters = _filters.copyWith(period: period));
    await _loadEntries();
  }

  Future<void> _clearFilters() async {
    setState(() => _filters = const JournalEntryFilters());
    await _loadEntries();
  }

  Future<void> _openFilters() async {
    final next = await showJournalFilterSheet(
      context,
      current: _filters,
      customFeelings: {
        ..._customFeelings,
        ..._entries.expand((entry) => entry.feelings),
      }.toList(),
    );
    if (next == null || !mounted) return;
    setState(() => _filters = next);
    await _loadEntries();
  }

  Future<void> _writeToday() async {
    if (!_isLoggedIn) {
      await _requireLogin();
      return;
    }

    await _openWizard();
  }

  Future<void> _editEntry(DiaryEntry entry) async {
    if (!mounted) return;
    await _openWizard(entry: entry);
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.deleteDiaryTitle),
          content: Text(l10n.deleteDiaryBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentRed,
              ),
              child: Text(l10n.deleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      await DiaryService.delete(entry.id);
      if (!mounted) return;
      await _loadEntries();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.diaryDeleted),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.diaryDeleteFailed),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  String _formatHeaderDate(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date).toUpperCase();
  }

  String _formatEntryDate(DiaryEntry entry) {
    final parsed = DateTime.tryParse(entry.entryDate);
    final datePart = parsed == null
        ? entry.entryDate
        : DateFormat('MMM d, yyyy').format(parsed);
    final created = DateTime.tryParse(entry.createdAt ?? '');
    if (created == null) return datePart;
    return '$datePart · ${DateFormat.jm().format(created.toLocal())}';
  }

  String _skyDisplayLabel(String? skyKey) {
    final opt = AppOptionCatalog.skyByKey(skyKey);
    if (opt == null) return '';
    return context.l10n.isTagalog ? opt.labelTl : opt.labelEn;
  }

  Future<void> _showEntrySummary(DiaryEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _JournalEntrySummarySheet(
        entry: entry,
        dateLabel: _formatEntryDate(entry),
        skyLabel: _skyDisplayLabel(entry.sky),
        onEdit: () {
          Navigator.of(ctx).pop();
          _editEntry(entry);
        },
        onDelete: () {
          Navigator.of(ctx).pop();
          _deleteEntry(entry);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final skyLabel = _skyDisplayLabel(_todayEntry?.sky);
    final prompt = JournalPrompts.forDate(now, isTagalog: l10n.isTagalog);

    return Scaffold(
      backgroundColor: context.pageBackground,
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
                              JournalFilterBar(
                                filters: _filters,
                                onPeriodChanged: _setPeriod,
                                onOpenMore: _openFilters,
                                onClear: _clearFilters,
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
                                        _filters.isNarrowed
                                            ? l10n.journalFilterEmpty
                                            : l10n.diaryEmpty,
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
                                      dateLabel: _formatEntryDate(entry),
                                      skyLabel: _skyDisplayLabel(entry.sky),
                                      onTap: () => _showEntrySummary(entry),
                                      onEdit: () => _editEntry(entry),
                                      onDelete: () => _deleteEntry(entry),
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
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.heading.withValues(alpha: 0.08),
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: context.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prompt,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
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
    required this.onEdit,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final String dateLabel;
  final String skyLabel;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final skyOpt = AppOptionCatalog.skyByKey(entry.sky);
    final accent = skyOpt?.accent ?? AppOptionCatalog.accentForSky(entry.sky);
    final preview = entry.hasNotes ? entry.displayNotesPreview : l10n.journalNoWrittenNotes;
    final feelings = entry.feelings;
    final imageUrl = ApiUrl.resolve(entry.imageUrl);

    return Material(
      color: context.cardBackground,
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
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 0, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) => Container(
                          color: context.chipBackground,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 22,
                            color: context.textSecondary
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    imageUrl != null ? 12 : 14,
                    14,
                    14,
                    14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: context.heading,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (skyOpt?.hasLookupIcon == true) ...[
                                    Icon(
                                      skyOpt!.icon,
                                      size: 12,
                                      color: context.heading,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    skyLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: context.heading,
                                    ),
                                  ),
                                ],
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
                              ? context.textPrimary
                              : context.textSecondary,
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
                                color: context.chipBackground,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                feeling,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.textSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _EntryActionButton(
                            icon: Icons.edit_outlined,
                            label: l10n.edit,
                            color: AppColors.primaryBlue,
                            onPressed: onEdit,
                          ),
                          const SizedBox(width: 4),
                          _EntryActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.deleteAction,
                            color: AppColors.accentRed,
                            onPressed: onDelete,
                          ),
                        ],
                      ),
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

class _EntryActionButton extends StatelessWidget {
  const _EntryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class _JournalEntrySummarySheet extends StatelessWidget {
  const _JournalEntrySummarySheet({
    required this.entry,
    required this.dateLabel,
    required this.skyLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final String dateLabel;
  final String skyLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final empty = l10n.journalSummaryEmpty;
    final skyOpt = AppOptionCatalog.skyByKey(entry.sky);
    final accent = skyOpt?.accent ?? AppOptionCatalog.accentForSky(entry.sky);
    final imageUrl = ApiUrl.resolve(entry.imageUrl);
    final notes = entry.hasNotes ? entry.displayNotesPreview : empty;
    final gratitude = entry.displayGratitude.trim();
    final impact = AppOptionCatalog.impactLabel(
      entry.impact,
      isTagalog: l10n.isTagalog,
    );
    final feelings = entry.feelings
        .map(
          (feeling) => AppOptionCatalog.feelingLabel(
            feeling,
            isTagalog: l10n.isTagalog,
          ),
        )
        .toList();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.78,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.heading,
                      ),
                    ),
                    if (skyLabel.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (skyOpt?.hasLookupIcon == true) ...[
                              Icon(
                                skyOpt!.icon,
                                size: 14,
                                color: context.heading,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              skyLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: context.heading,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (imageUrl != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, error, stackTrace) => Container(
                              color: context.chipBackground,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _SummaryBlock(
                      label: l10n.journalSummaryFeelings,
                      child: feelings.isEmpty
                          ? Text(
                              empty,
                              style: TextStyle(
                                color: context.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: feelings
                                  .map(
                                    (feeling) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.chipBackground,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        feeling,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _SummaryBlock(
                      label: l10n.journalSummaryImpact,
                      child: Text(
                        impact.isEmpty ? empty : impact,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: impact.isEmpty
                              ? context.textSecondary
                              : context.textPrimary,
                          fontStyle: impact.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SummaryBlock(
                      label: l10n.journalNotesShort,
                      child: Text(
                        notes,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: entry.hasNotes
                              ? context.textPrimary
                              : context.textSecondary,
                          fontStyle: entry.hasNotes
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                    if (gratitude.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SummaryBlock(
                        label: l10n.journalGratitudeLabel,
                        child: Text(
                          gratitude,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(l10n.edit),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppColors.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: Text(l10n.deleteAction),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentRed,
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppColors.accentRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
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

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

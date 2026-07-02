import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/diary_entry.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import 'diary_editor_screen.dart';
import 'diary_service.dart';
import 'widgets/diary_body_html.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<DiaryEntry> _entries = [];
  bool _loading = false;
  bool _isLoggedIn = false;

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
      await _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    try {
      final entries = await DiaryService.fetchEntries();
      if (mounted) setState(() => _entries = entries);
    } catch (_) {
      if (mounted) setState(() => _entries = []);
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
      await _loadEntries();
    }
  }

  Future<void> _openEditor({DiaryEntry? entry}) async {
    if (!_isLoggedIn) {
      await _requireLogin();
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DiaryEditorScreen(existing: entry),
      ),
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
      await _openEditor(entry: today);
    } catch (_) {
      if (!mounted) return;
      await _openEditor();
    }
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat.yMMMEd().format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diaryTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writeToday,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.edit_note),
        label: Text(l10n.writeToday),
      ),
      body: !_isLoggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.diaryLoginRequired,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _requireLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: Text(l10n.login),
                    ),
                  ],
                ),
              ),
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadEntries,
                  child: _entries.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                l10n.diaryEmpty,
                                style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                          itemCount: _entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openEditor(entry: entry),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(entry.entryDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      if (entry.title != null &&
                                          entry.title!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          entry.title!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      DiaryBodyHtml(html: entry.bodyHtml),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

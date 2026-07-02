import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/bible_models.dart';
import '../../core/theme/app_colors.dart';
import 'bible_reader_screen.dart';
import 'bible_service.dart';

class BibleHomeScreen extends StatefulWidget {
  const BibleHomeScreen({super.key});

  @override
  State<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

class _BibleHomeScreenState extends State<BibleHomeScreen> {
  List<BibleBook> _books = [];
  bool _loading = true;
  String _filter = '';
  String? _loadedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = LocaleScope.of(context).locale.code;
    if (_loadedLocale != locale) {
      _loadedLocale = locale;
      _loadBooks(locale: locale);
    }
  }

  Future<void> _loadBooks({String? locale}) async {
    final activeLocale = locale ?? LocaleScope.of(context).locale.code;
    setState(() => _loading = true);
    try {
      final books = await BibleService.fetchBooks(locale: activeLocale);
      if (mounted) setState(() => _books = books);
    } catch (_) {
      if (mounted) setState(() => _books = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _filter.trim().toLowerCase();
    final filtered = _books.where((book) {
      if (query.isEmpty) return true;
      return book.name.toLowerCase().contains(query);
    }).toList();

    final oldTestament = filtered.where((b) => b.testament == 'OT').toList();
    final newTestament = filtered.where((b) => b.testament == 'NT').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bibleTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) => setState(() => _filter = value),
                        decoration: InputDecoration(
                          hintText: l10n.searchBibleBooks,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.bibleLanguageNote,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _loadBooks(
                      locale: LocaleScope.of(context).locale.code,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        if (oldTestament.isNotEmpty) ...[
                          _SectionTitle(l10n.oldTestament),
                          ...oldTestament.map(_bookTile),
                        ],
                        if (newTestament.isNotEmpty) ...[
                          _SectionTitle(l10n.newTestament),
                          ...newTestament.map(_bookTile),
                        ],
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                l10n.noBibleBooksFound,
                                style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                ),
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

  Widget _bookTile(BibleBook book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          child: const Icon(Icons.menu_book, color: AppColors.primaryBlue),
        ),
        title: Text(
          book.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(context.l10n.chaptersLabel(book.chapters)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openChapterPicker(book),
      ),
    );
  }

  Future<void> _openChapterPicker(BibleBook book) async {
    final chapter = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book.name,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SizedBox(
                    height: 280,
                    child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: book.chapters,
                    itemBuilder: (context, index) {
                      final chapterNumber = index + 1;
                      return FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(chapterNumber),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('$chapterNumber'),
                      );
                    },
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || chapter == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleReaderScreen(
          bookId: book.id,
          bookName: book.name,
          chapter: chapter,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
      ),
    );
  }
}

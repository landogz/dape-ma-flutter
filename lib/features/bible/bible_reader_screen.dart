import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/bible_models.dart';
import '../../core/theme/app_colors.dart';
import 'bible_service.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapter,
  });

  final String bookId;
  final String bookName;
  final int chapter;

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  BiblePassage? _passage;
  bool _loading = true;
  late int _chapter;
  String? _loadedLocale;

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = LocaleScope.of(context).locale.code;
    if (_loadedLocale != locale) {
      _loadedLocale = locale;
      _loadPassage(locale: locale);
    }
  }

  Future<void> _loadPassage({String? locale}) async {
    final activeLocale = locale ?? LocaleScope.of(context).locale.code;
    setState(() => _loading = true);
    try {
      final passage = await BibleService.fetchPassage(
        book: widget.bookId,
        chapter: _chapter,
        locale: activeLocale,
      );
      if (mounted) setState(() => _passage = passage);
    } catch (_) {
      if (mounted) setState(() => _passage = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _changeChapter(int delta) {
    final next = _chapter + delta;
    if (next < 1) return;
    setState(() => _chapter = next);
    _loadPassage(locale: LocaleScope.of(context).locale.code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookName} $_chapter'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _chapter > 1 ? () => _changeChapter(-1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: () => _changeChapter(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _passage == null
              ? Center(child: Text(l10n.bibleLoadFailed))
              : RefreshIndicator(
                  onRefresh: () => _loadPassage(
                    locale: LocaleScope.of(context).locale.code,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      Text(
                        _passage!.reference,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _passage!.translation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(height: 20),
                      ..._passage!.verses.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SelectableText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${line.verse} ',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: line.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(height: 1.55),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_passage!.verses.isEmpty && _passage!.text.isNotEmpty)
                        SelectableText(
                          _passage!.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.55,
                              ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../shell/main_shell_screen.dart';
import 'kid_listo_quote_service.dart';

class KidListoWelcomeScreen extends StatefulWidget {
  const KidListoWelcomeScreen({
    super.key,
    required this.initialPosts,
    this.replaceOnContinue = true,
  });

  final List<Post> initialPosts;
  final bool replaceOnContinue;

  @override
  State<KidListoWelcomeScreen> createState() => _KidListoWelcomeScreenState();
}

class _KidListoWelcomeScreenState extends State<KidListoWelcomeScreen> {
  bool _loading = true;
  String _brand = 'Kid Listo Says';
  String _brandTagline = '';
  String _message = '';
  String _attribution = 'Kid Listo';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuote());
  }

  Future<void> _loadQuote() async {
    try {
      final locale = LocaleScope.of(context).locale.code;
      final quote = await KidListoQuoteService.fetchRandom(locale: locale);
      if (!mounted) return;
      setState(() {
        _brand = quote?.brand ?? 'Kid Listo Says';
        _brandTagline = quote?.brandTagline ?? '';
        _message = quote?.message ?? '';
        _attribution = quote?.attribution?.isNotEmpty == true
            ? quote!.attribution!
            : 'Kid Listo';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openHome() {
    if (widget.replaceOnContinue) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainShellScreen(initialPosts: widget.initialPosts),
        ),
      );
      return;
    }

    Navigator.of(context).maybePop();
  }

  Future<void> _shuffleQuote() async {
    setState(() => _loading = true);
    await _loadQuote();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = DateFormat.yMMMMEEEEd().format(DateTime.now());
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final titleAccent =
        isDark ? const Color(0xFF7DD3FC) : AppColors.primaryBlue;
    final displayMessage =
        _message.isNotEmpty ? _message : l10n.kidListoQuoteFallback;

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
                        widget.replaceOnContinue ? l10n.skip : l10n.close,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
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
                      l10n.kidListoMotivationalBadge,
                      style: const TextStyle(
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: isDark
                        ? Border.all(color: context.borderSubtle)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.35 : 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _loading
                      ? SizedBox(
                          height: 160,
                          child: Center(
                            child: CircularProgressIndicator(color: titleAccent),
                          ),
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
                                    color: titleAccent,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _brandTagline.isNotEmpty
                                  ? _brandTagline
                                  : l10n.kidListoMotivationalTagline,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              displayMessage,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    height: 1.45,
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '— $_attribution',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: titleAccent,
                                    fontWeight: FontWeight.w700,
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
                    icon: Icon(
                      widget.replaceOnContinue
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      widget.replaceOnContinue
                          ? l10n.continueToApp
                          : l10n.done,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _shuffleQuote,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.casino_outlined),
                    label: Text(l10n.anotherKidListoQuote),
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

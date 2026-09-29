import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/diary_entry.dart';
import '../auth/login_screen.dart';
import '../diary/diary_list_screen.dart';
import '../diary/diary_service.dart';
import '../diary/widgets/journal_wizard/journal_wizard_sheet.dart';
import 'care_colors.dart';
import 'calm_corner_screen.dart';
import 'get_support_screen.dart';
import 'self_care_toolkit_screen.dart';
import 'widgets/daily_reflection_card.dart';

class CareHubScreen extends StatefulWidget {
  const CareHubScreen({super.key});

  @override
  State<CareHubScreen> createState() => _CareHubScreenState();
}

class _CareHubScreenState extends State<CareHubScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _openingJournal = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _ensureLogin() async {
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) return true;
    if (!mounted) return false;
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return loggedIn == true;
  }

  Future<void> _startDailyReflection() async {
    if (_openingJournal) return;
    if (!await _ensureLogin()) return;
    if (!mounted) return;

    setState(() => _openingJournal = true);
    try {
      DiaryEntry? existing;
      try {
        existing = await DiaryService.fetchToday();
      } catch (_) {
        existing = null;
      }
      if (!mounted) return;

      await showJournalWizard(
        context,
        existing: existing,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.diarySaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _openingJournal = false);
    }
  }

  bool _matches(String haystack) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return haystack.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.viewPaddingOf(context).top;
    final canPop = Navigator.of(context).canPop();

    final showReflection = _matches(
      '${l10n.careDailyReflection} ${l10n.careDailyReflectionPrompt} ${l10n.careStartWriting}',
    );
    final showJournal =
        _matches('${l10n.careSpeedJournal} ${l10n.careSpeedJournalBody}');
    final showToolkit =
        _matches('${l10n.careSpeedToolkit} ${l10n.careSpeedToolkitBody}');
    final showSupport =
        _matches('${l10n.careSpeedSupport} ${l10n.careSpeedSupportBody}');
    final showCalm =
        _matches('${l10n.careCalmCorner} ${l10n.careCalmCornerBody}');

    final speedCards = <Widget>[
      if (showJournal)
        _SpeedCard(
          title: l10n.careSpeedJournal,
          body: l10n.careSpeedJournalBody,
          logoAsset: CareHubAssets.journal,
          fallbackIcon: Icons.menu_book_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DiaryListScreen()),
          ),
        ),
      if (showToolkit)
        _SpeedCard(
          title: l10n.careSpeedToolkit,
          body: l10n.careSpeedToolkitBody,
          logoAsset: CareHubAssets.selfCare,
          fallbackIcon: Icons.volunteer_activism_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SelfCareToolkitScreen()),
          ),
        ),
      if (showSupport)
        _SpeedCard(
          title: l10n.careSpeedSupport,
          body: l10n.careSpeedSupportBody,
          logoAsset: CareHubAssets.support,
          fallbackIcon: Icons.handshake_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GetSupportScreen()),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: CareColors.mintSoft,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      CareHubAssets.headerBanner,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              CareColors.tealMid,
                              CareColors.teal,
                              CareColors.tealDark,
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            CareColors.tealDark.withValues(alpha: 0.28),
                            CareColors.tealDark.withValues(alpha: 0.52),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, top + 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (canPop) ...[
                              Material(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () =>
                                      Navigator.of(context).maybePop(),
                                  child: const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Image.asset(
                              CareHubAssets.logoWhite,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.careTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.careSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            color: CareColors.greenText,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: l10n.careSearchHint,
                            hintStyle: const TextStyle(
                              color: CareColors.mutedText,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: CareColors.mutedText,
                              size: 18,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 32,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (showReflection) ...[
                  DailyReflectionCard(
                    busy: _openingJournal,
                    onStartWriting: _startDailyReflection,
                  ),
                  const SizedBox(height: 32),
                ],
                Text(
                  l10n.careSpeedDial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: CareColors.heading,
                  ),
                ),
                const SizedBox(height: 14),
                if (speedCards.isNotEmpty)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < speedCards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: speedCards[i]),
                        ],
                      ],
                    ),
                  ),
                if (showCalm) ...[
                  const SizedBox(height: 14),
                  _CalmCornerCard(
                    title: l10n.careCalmCorner,
                    body: l10n.careCalmCornerBody,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CalmCornerScreen(),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class CareHubAssets {
  static const journal = 'assets/care/care_journal.png';
  static const selfCare = 'assets/care/care_selfcare.png';
  static const support = 'assets/care/care_support.png';
  static const calm = 'assets/care/care_calm.png';
  static const headerBanner = 'assets/care/care_header_banner.png';
  static const logoWhite = 'assets/care/care_logo_white.png';
}

class _SpeedCard extends StatelessWidget {
  const _SpeedCard({
    required this.title,
    required this.body,
    required this.logoAsset,
    required this.fallbackIcon,
    required this.onTap,
  });

  final String title;
  final String body;
  final String logoAsset;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CareColors.cardFill,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: CareColors.cardFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: CareColors.cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: CareColors.tealDark.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 44,
                  child: Image.asset(
                    logoAsset,
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      fallbackIcon,
                      color: CareColors.tealDark,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.15,
                    color: CareColors.heading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: CareColors.mutedText,
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

class _CalmCornerCard extends StatelessWidget {
  const _CalmCornerCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CareColors.cardFill,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: CareColors.cardFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: CareColors.cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: CareColors.tealDark.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 72,
                  child: Image.asset(
                    CareHubAssets.calm,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.self_improvement_rounded,
                      color: CareColors.teal,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          height: 1.15,
                          color: CareColors.heading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: CareColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2, bottom: 2),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: CareColors.tealDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/care_support_item.dart';
import '../../../core/utils/api_url.dart';
import '../../../core/theme/app_colors.dart';
import '../care_colors.dart';
import '../care_launchers.dart';
import '../care_support_service.dart';
import '../calm_corner_screen.dart';
import '../../../core/theme/app_theme_colors.dart';

/// Shared loader + empty/error states for Get Support subpages.
mixin CareSupportListMixin<T extends StatefulWidget> on State<T> {
  List<CareSupportItem> items = [];
  bool loading = true;

  String get supportCategory;

  Future<void> loadSupportItems() async {
    setState(() => loading = true);
    try {
      final locale = context.l10n.isTagalog ? 'tl' : 'en';
      final list = await CareSupportService.fetch(
        category: supportCategory,
        locale: locale,
      );
      if (!mounted) return;
      setState(() => items = list);
    } catch (_) {
      if (mounted) setState(() => items = []);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class HotlinesScreen extends StatefulWidget {
  const HotlinesScreen({super.key});

  @override
  State<HotlinesScreen> createState() => _HotlinesScreenState();
}

class _HotlinesScreenState extends State<HotlinesScreen>
    with CareSupportListMixin {
  @override
  String get supportCategory => 'hotline';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadSupportItems());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.pageBackground,
        foregroundColor: CareColors.textOf(context),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              l10n.careHotlines,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              l10n.careHotlinesSubtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: CareColors.teal))
          : RefreshIndicator(
              color: CareColors.headingOf(context),
              onRefresh: loadSupportItems,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _HotlineCard(item: item);
                },
              ),
            ),
    );
  }
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.item});

  final CareSupportItem item;

  @override
  Widget build(BuildContext context) {
    final phone = item.phone?.trim() ?? '';
    final primaryPhone = phone.split('|').first.trim();

    return Material(
      color: context.cardBackground,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _LogoAvatar(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.role == null || item.role!.isEmpty
                        ? item.title
                        : '${item.title} | ${item.role}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: CareColors.textOf(context),
                      fontSize: 14,
                    ),
                  ),
                  if ((item.meta ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: CareColors.headingOf(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.meta!,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: CareColors.textOf(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (primaryPhone.isNotEmpty)
              IconButton(
                tooltip: 'Call',
                onPressed: () => launchCareTel(primaryPhone),
                icon: Icon(Icons.phone_in_talk_rounded,
                    color: CareColors.headingOf(context)),
              ),
          ],
        ),
      ),
    );
  }
}

class CounselingScreen extends StatefulWidget {
  const CounselingScreen({super.key});

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen>
    with CareSupportListMixin {
  @override
  String get supportCategory => 'counseling';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadSupportItems());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.pageBackground,
        foregroundColor: CareColors.textOf(context),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              l10n.careCounseling,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              l10n.careCounselingBody,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: CareColors.teal))
          : RefreshIndicator(
              color: CareColors.headingOf(context),
              onRefresh: loadSupportItems,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _CounselingCard(item: item);
                },
              ),
            ),
    );
  }
}

class _CounselingCard extends StatelessWidget {
  const _CounselingCard({required this.item});

  final CareSupportItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoAvatar(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: CareColors.textOf(context),
                      fontSize: 14,
                    ),
                  ),
                  if ((item.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(Icons.info_outline,
                              size: 14, color: CareColors.headingOf(context)),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.description!,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if ((item.webUrl ?? '').isNotEmpty)
              IconButton(
                tooltip: 'Open website',
                onPressed: () => launchCareWeb(item.webUrl!),
                icon: Icon(Icons.link_rounded, color: CareColors.headingOf(context)),
              ),
          ],
        ),
      ),
    );
  }
}

class CrisisSupportScreen extends StatefulWidget {
  const CrisisSupportScreen({super.key});

  @override
  State<CrisisSupportScreen> createState() => _CrisisSupportScreenState();
}

class _CrisisSupportScreenState extends State<CrisisSupportScreen> {
  List<CareSupportItem> _emergency = [];
  List<CareSupportItem> _resources = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final locale = context.l10n.isTagalog ? 'tl' : 'en';
      final emergency = await CareSupportService.fetch(
        category: 'crisis_emergency',
        locale: locale,
      );
      final resources = await CareSupportService.fetch(
        category: 'crisis_resource',
        locale: locale,
      );
      if (!mounted) return;
      setState(() {
        _emergency = emergency;
        _resources = resources;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _emergency = [];
          _resources = [];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showResourceModal(CareSupportItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded,
                        color: CareColors.headingOf(context)),
                  ),
                ),
                Icon(Icons.info_rounded,
                    size: 56, color: CareColors.headingOf(context)),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: CareColors.textOf(context),
                  ),
                ),
                const SizedBox(height: 12),
                ...item.body.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      p,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: CareColors.textOf(context).withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(String? key) {
    return switch (key) {
      'plan' => Icons.edit_note_rounded,
      'tips' => Icons.lightbulb_outline_rounded,
      'friend' => Icons.chat_bubble_outline_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final emergency = _emergency.isNotEmpty ? _emergency.first : null;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.pageBackground,
        foregroundColor: CareColors.textOf(context),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              l10n.careCrisis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              l10n.careCrisisSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CareColors.teal))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (emergency != null)
                  Material(
                    color: AppColors.softRed,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final phone = emergency.phone?.trim();
                        if (phone != null && phone.isNotEmpty) {
                          launchCareTel(phone);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.fireEngineRed),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                emergency.title,
                                style: const TextStyle(
                                  color: AppColors.fireEngineRed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const Icon(Icons.phone_in_talk_rounded,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Text(
                  l10n.careCrisisUnsure,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: CareColors.textOf(context),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                ..._resources.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: context.cardBackground,
                      elevation: 1,
                      shadowColor: Colors.black12,
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        onTap: () => _showResourceModal(item),
                        leading: CircleAvatar(
                          backgroundColor: CareColors.mintOf(context),
                          child: Icon(
                            _iconFor(item.iconKey),
                            color: CareColors.headingOf(context),
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: CareColors.textOf(context),
                          ),
                        ),
                        subtitle: Text(item.description ?? ''),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HotlinesScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: CareColors.tealDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.careGoToHotlines),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CalmCornerScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: CareColors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.careGoToCalmCorner),
                  ),
                ),
              ],
            ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  const _LogoAvatar({required this.item});

  final CareSupportItem item;

  @override
  Widget build(BuildContext context) {
    final url = ApiUrl.resolve(item.logoUrl);
    final initialRaw = (item.logoInitial ?? item.title).trim();
    final initial = initialRaw.isEmpty
        ? '?'
        : initialRaw.substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: 26,
      backgroundColor: CareColors.mintOf(context),
      backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
      child: (url == null || url.isEmpty)
          ? Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: CareColors.headingOf(context),
              ),
            )
          : null,
    );
  }
}

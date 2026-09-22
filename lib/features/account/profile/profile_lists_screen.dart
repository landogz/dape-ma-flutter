import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/api_url.dart';
import '../widgets/badge_medallion.dart';
import '../widgets/profile_list_widgets.dart';
import 'badges_screen.dart';
import 'profile_models.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({
    super.key,
    required this.certificates,
    this.userName,
  });

  final List<ProfileCertificate> certificates;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            ProfileListHeader(title: l10n.myCertificates),
            Expanded(
              child: certificates.isEmpty
                  ? ProfileListEmptyState(
                      icon: Icons.workspace_premium_rounded,
                      title: l10n.noCertificatesYet,
                      body: l10n.noCertificatesBody,
                      iconColor: const Color(0xFFD97706),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        28 + bottomSafe,
                      ),
                      itemCount: certificates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = certificates[index];
                        final earned = item.earnedAt == null
                            ? null
                            : DateTime.tryParse(item.earnedAt!);
                        final thumb = ApiUrl.resolve(item.mediaUrl);
                        return Material(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CertificateDetailScreen(
                                    certificate: item,
                                    userName: userName,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: context.borderSubtle),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha:
                                          context.isDarkMode ? 0.25 : 0.05,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: thumb != null
                                        ? Image.network(
                                            thumb,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const _CertThumbPlaceholder(),
                                          )
                                        : const _CertThumbPlaceholder(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.certificateOfCompletion,
                                          style: TextStyle(
                                            color: context.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.contestTitle?.trim().isNotEmpty ==
                                                  true
                                              ? item.contestTitle!
                                              : item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: context.textPrimary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (earned != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${l10n.completedOn} ${DateFormat.yMMMMd().format(earned)}',
                                            style: TextStyle(
                                              color: context.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primaryBlue
                                        .withValues(alpha: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertThumbPlaceholder extends StatelessWidget {
  const _CertThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: AppColors.accentYellow,
      ),
    );
  }
}

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({
    super.key,
    required this.certificate,
    this.userName,
  });

  final ProfileCertificate certificate;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final earned = certificate.earnedAt == null
        ? null
        : DateTime.tryParse(certificate.earnedAt!);
    final course = certificate.contestTitle?.trim().isNotEmpty == true
        ? certificate.contestTitle!
        : certificate.title;
    final name = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim()
        : l10n.youAreSignedIn;
    final media = ApiUrl.resolve(certificate.mediaUrl);
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            ProfileListHeader(
              title: l10n.myCertificates,
              subtitle: course,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 28 + bottomSafe),
                children: [
                  if (media != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 0.72,
                        child: Image.network(
                          media,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _CertificateCard(
                            course: course,
                            name: name,
                            earned: earned,
                          ),
                        ),
                      ),
                    )
                  else
                    _CertificateCard(
                      course: course,
                      name: name,
                      earned: earned,
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

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.course,
    required this.name,
    required this.earned,
  });

  final String course;
  final String name;
  final DateTime? earned;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF055498),
              Color(0xFF123A60),
              Color(0xFF0B4F86),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.accentYellow,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.certificateOfCompletion.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.certificatePresentedTo,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.certificateForCompleting,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.accentYellow,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (earned != null)
              Text(
                DateFormat.yMMMMd().format(earned!),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'DAPE-MA',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GainsScreen extends StatelessWidget {
  const GainsScreen({
    super.key,
    required this.gains,
    this.badges = const [],
  });

  final List<ProfileGain> gains;
  final List<ProfileBadge> badges;

  int get _xp {
    final winners = gains.where((g) => g.status == 'winner').length;
    final approved = gains.where((g) => g.status == 'approved').length;
    final earnedBadges = badges.where((b) => b.earned).length;
    return (earnedBadges * 50) + (winners * 75) + (approved * 25) + (gains.length * 10);
  }

  int get _level => (_xp ~/ 100) + 1;

  double get _levelProgress => (_xp % 100) / 100.0;

  String _levelTitle(BuildContext context) {
    final l10n = context.l10n;
    final level = _level;
    if (level >= 5) return l10n.levelChampion;
    if (level >= 3) return l10n.levelExplorer;
    return l10n.levelBeginner;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'winner':
        return const Color(0xFF16A34A);
      case 'approved':
        return AppColors.primaryBlue;
      case 'rejected':
        return AppColors.accentRed;
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final earnedBadges = badges.where((b) => b.earned).toList();
    final lockedBadges = badges.where((b) => !b.earned).toList();
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4,
                bottom: 28,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF123A60),
                    Color(0xFF055498),
                    Color(0xFF1D4ED8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.myGains,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.accentYellow,
                    size: 56,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${l10n.levelLabel(_level)} ${_levelTitle(context)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.xpLabel(_xp),
                    style: TextStyle(
                      color: AppColors.accentYellow.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _levelProgress.clamp(0.05, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.accentYellow,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.xpToNextLevel(100 - (_xp % 100)),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 22, 20, 28 + bottomSafe),
                decoration: BoxDecoration(
                  color: context.pageBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badges.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.earnedBadgesSection,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BadgesScreen(badges: badges),
                                ),
                              );
                            },
                            child: Text(
                              l10n.seeAll,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: (earnedBadges.isNotEmpty
                                  ? earnedBadges
                                  : badges.take(3).toList())
                              .length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final list = earnedBadges.isNotEmpty
                                ? earnedBadges
                                : badges.take(3).toList();
                            final badge = list[index];
                            return Column(
                              children: [
                                BadgeMedallion(
                                  icon: profileBadgeIcon(badge.key),
                                  color: profileBadgeColor(badge.color),
                                  earned: badge.earned,
                                  size: 58,
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    badge.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (lockedBadges.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          l10n.lockedBadgesSection,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: lockedBadges.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final badge = lockedBadges[index];
                              return Column(
                                children: [
                                  BadgeMedallion(
                                    icon: profileBadgeIcon(badge.key),
                                    color: profileBadgeColor(badge.color),
                                    earned: false,
                                    size: 58,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 72,
                                    child: Text(
                                      badge.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                    ],
                    Text(
                      l10n.contestEntriesSection,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (gains.isEmpty)
                      ProfileListEmptyState(
                        icon: Icons.emoji_events_outlined,
                        title: l10n.noGainsYet,
                        body: l10n.noGainsBody,
                      )
                    else
                      ...gains.map((item) {
                        final submitted = item.submittedAt == null
                            ? null
                            : DateTime.tryParse(item.submittedAt!);
                        final statusColor = _statusColor(item.status);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: context.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.emoji_events_rounded,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          color: context.textPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (item.contestTitle != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          item.contestTitle!,
                                          style: TextStyle(
                                            color: context.textSecondary,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              item.status.toUpperCase(),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (submitted != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat.yMMMd()
                                                  .format(submitted),
                                              style: TextStyle(
                                                color:
                                                    context.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.emptyTitle,
    required this.emptyBody,
    this.onOpenPost,
    this.listIcon,
    this.accentColor,
  });

  final String title;
  final List<ProfileActivityItem> items;
  final String emptyTitle;
  final String emptyBody;
  final void Function(ProfileActivityItem item)? onOpenPost;
  final IconData? listIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final accent = accentColor ?? AppColors.primaryBlue;
    final headerIcon = listIcon ?? Icons.article_outlined;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileListHeader(
              title: title,
              subtitle: l10n.activityItemsCount(items.length),
            ),
            Expanded(
              child: items.isEmpty
                  ? ProfileListEmptyState(
                      icon: headerIcon,
                      title: emptyTitle,
                      body: emptyBody,
                      iconColor: accent,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        28 + bottomSafe,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final style = profileCategoryStyle(item.categorySlug);
                        return ProfileContentTile(
                          title: item.title,
                          subtitle: item.subtitle,
                          icon: listIcon ?? style.icon,
                          iconColor: style.color,
                          iconBackground: style.background,
                          onTap: () {
                            if (onOpenPost != null) onOpenPost!(item);
                          },
                          trailing: onOpenPost == null
                              ? const SizedBox.shrink()
                              : Icon(
                                  Icons.chevron_right_rounded,
                                  color: context.textSecondary
                                      .withValues(alpha: 0.7),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import 'home_header.dart';

class WhatsNewItem {
  const WhatsNewItem({
    required this.iconAsset,
    required this.iconBg,
    required this.prefix,
    required this.highlight,
    this.onTap,
  });

  final String iconAsset;
  final Color iconBg;
  final String prefix;
  final String highlight;
  final VoidCallback? onTap;
}

/// What's New banner (carousel slide).
class WhatsNewCard extends StatelessWidget {
  const WhatsNewCard({
    super.key,
    required this.items,
  });

  final List<WhatsNewItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = items.take(2).toList();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 148,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 118, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeWhatsNew.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF8FA8C8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (rows.isEmpty)
                      Text(
                        l10n.homeWhatsNewEmpty,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF64748B),
                        ),
                      )
                    else
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) ...[
                          const SizedBox(height: 6),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEF2F7),
                          ),
                          const SizedBox(height: 6),
                        ],
                        _WhatsNewRow(item: rows[i]),
                      ],
                  ],
                ),
              ),
              Positioned(
                right: -16,
                top: -8,
                bottom: -10,
                child: SizedBox(
                  width: 132,
                  child: Image.asset(
                    HomeAssets.whatsNewArt,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.campaign_rounded,
                      color: AppColors.primaryBlue,
                      size: 56,
                    ),
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

class _WhatsNewRow extends StatelessWidget {
  const _WhatsNewRow({required this.item});

  final WhatsNewItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              item.onTap!();
            },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                item.iconAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.prefix} ',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    TextSpan(
                      text: item.highlight,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

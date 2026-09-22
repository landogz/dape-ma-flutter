import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';

class HomeActivityRow {
  const HomeActivityRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isLesson,
  });

  final int id;
  final String title;
  final String subtitle;
  final bool isLesson;
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({
    super.key,
    required this.items,
    required this.onTap,
    this.onSeeAll,
  });

  final List<HomeActivityRow> items;
  final ValueChanged<HomeActivityRow> onTap;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeRecentActivity,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryBlue,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              l10n.homeActivityEmptyBody,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          )
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => onTap(item),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.isLesson
                                ? const Color(0xFFDCFCE7)
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.isLesson
                                ? Icons.check_rounded
                                : Icons.menu_book_outlined,
                            color: item.isLesson
                                ? const Color(0xFF16A34A)
                                : AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryBlue,
                                ),
                              ),
                              if (item.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

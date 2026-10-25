import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

enum ProfilePhotoChoice { change, remove }

class ProfilePhotoSheet {
  ProfilePhotoSheet._();

  static Future<ProfilePhotoChoice?> show(
    BuildContext context, {
    required String title,
    required String changeLabel,
    required String removeLabel,
    required String cancelLabel,
    required bool canRemove,
  }) {
    return showModalBottomSheet<ProfilePhotoChoice>(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderSubtle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.heading,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _PhotoActionTile(
                  icon: Icons.photo_library_outlined,
                  label: changeLabel,
                  onTap: () => Navigator.pop(ctx, ProfilePhotoChoice.change),
                ),
                if (canRemove) ...[
                  const SizedBox(height: 8),
                  _PhotoActionTile(
                    icon: Icons.delete_outline_rounded,
                    label: removeLabel,
                    danger: true,
                    onTap: () => Navigator.pop(ctx, ProfilePhotoChoice.remove),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: context.textSecondary,
                  ),
                  child: Text(cancelLabel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhotoActionTile extends StatelessWidget {
  const _PhotoActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.fireEngineRed : context.heading;

    return Material(
      color: danger
          ? AppColors.fireEngineRed.withValues(alpha: 0.08)
          : context.mutedSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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

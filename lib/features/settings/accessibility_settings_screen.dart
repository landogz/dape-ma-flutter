import 'package:flutter/material.dart';

import '../../core/accessibility/accessibility_controller.dart';
import '../../core/accessibility/accessibility_scope.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../account/widgets/settings_hero_header.dart';
import '../account/widgets/settings_menu_tile.dart';
import '../settings/widgets/language_picker_card.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  Future<void> _showTextSizeSheet(
    BuildContext context,
    AccessibilityController a11y,
  ) async {
    final original = a11y.textScale;
    var temp = original;
    var saved = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              // Keep sheet chrome at base scale so the Aa preview stays accurate.
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    28 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.textSize,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aa',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 18 * temp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(temp * 100).round()}%',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: temp,
                        min: 0.9,
                        max: 1.4,
                        divisions: 5,
                        activeColor: AppColors.primaryBlue,
                        label: '${(temp * 100).round()}%',
                        onChanged: (value) {
                          setModalState(() => temp = value);
                          // Live-apply across the whole app while dragging.
                          a11y.previewTextScale(value);
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            await a11y.setTextScale(temp);
                            saved = true;
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(context.l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      // Dismiss without Save → restore last persisted size.
      if (!saved) {
        a11y.previewTextScale(original);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a11y = context.accessibility;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            SettingsHeroHeader(
              showBack: true,
              icon: Icons.accessibility_new_rounded,
              title: l10n.accessibility,
              subtitle: l10n.accessibilityIntro,
              iconBackground: const Color(0xFF38BDF8),
            ),
            const SizedBox(height: 22),
            SettingsMenuTile(
              title: l10n.textSize,
              subtitle:
                  '${l10n.textSizeBody} (${(a11y.textScale * 100).round()}%)',
              icon: Icons.text_increase_rounded,
              iconBackground: const Color(0xFFDBEAFE),
              iconColor: AppColors.primaryBlue,
              onTap: () => _showTextSizeSheet(context, a11y),
            ),
            const SizedBox(height: 10),
            SettingsMenuTile(
              title: l10n.darkMode,
              subtitle: l10n.darkModeBody,
              icon: Icons.dark_mode_rounded,
              iconBackground: const Color(0xFFEDE9FE),
              iconColor: AppColors.accentPurple,
              trailing: Switch.adaptive(
                value: a11y.darkMode,
                activeTrackColor: AppColors.primaryBlue,
                onChanged: a11y.setDarkMode,
              ),
            ),
            const SizedBox(height: 10),
            SettingsMenuTile(
              title: l10n.reduceMotion,
              subtitle: l10n.reduceMotionBody,
              icon: Icons.animation_rounded,
              iconBackground: const Color(0xFFFCE7F3),
              iconColor: AppColors.accentPurple,
              trailing: Switch.adaptive(
                value: a11y.reduceMotion,
                activeTrackColor: AppColors.primaryBlue,
                onChanged: a11y.setReduceMotion,
              ),
            ),
            const SizedBox(height: 10),
            SettingsMenuTile(
              title: l10n.highContrast,
              subtitle: l10n.highContrastBody,
              icon: Icons.contrast_rounded,
              iconBackground: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              trailing: Switch.adaptive(
                value: a11y.highContrast,
                activeTrackColor: AppColors.primaryBlue,
                onChanged: a11y.setHighContrast,
              ),
            ),
            const SizedBox(height: 10),
            SettingsMenuTile(
              title: l10n.readAloud,
              subtitle: l10n.readAloudBody,
              icon: Icons.record_voice_over_rounded,
              iconBackground: const Color(0xFFFCE7F3),
              iconColor: AppColors.accentPurple,
              trailing: Switch.adaptive(
                value: a11y.readAloud,
                activeTrackColor: AppColors.primaryBlue,
                onChanged: a11y.setReadAloud,
              ),
            ),
            const SizedBox(height: 10),
            SettingsMenuTile(
              title: l10n.captions,
              subtitle: l10n.captionsBody,
              icon: Icons.closed_caption_rounded,
              iconBackground: const Color(0xFFDBEAFE),
              iconColor: AppColors.primaryBlue,
              trailing: Switch.adaptive(
                value: a11y.captions,
                activeTrackColor: AppColors.primaryBlue,
                onChanged: a11y.setCaptions,
              ),
            ),
            const SizedBox(height: 18),
            const LanguagePickerCard(),
            const SizedBox(height: 20),
            Text(
              l10n.accessibilityFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue.withValues(alpha: 0.65),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

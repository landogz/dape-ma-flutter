import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/options/app_option_catalog.dart';
import '../../../core/options/app_option_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../care_colors.dart';
import 'audio/relaxing_audio_screen.dart';
import 'breathing/guided_breathing_screen.dart';
import 'color_fun/color_fun_screen.dart';
import 'meditation/meditation_screen.dart';
import 'stretch/stretch_breaks_screen.dart';
import 'visualization/visualization_screen.dart';
import 'widgets/calm_app_bar.dart';
import 'widgets/calm_info_sheet.dart';
import 'widgets/calm_menu_card.dart';

class CalmCornerScreen extends StatefulWidget {
  const CalmCornerScreen({super.key});

  @override
  State<CalmCornerScreen> createState() => _CalmCornerScreenState();
}

class _CalmCornerScreenState extends State<CalmCornerScreen> {
  @override
  void initState() {
    super.initState();
    AppOptionCatalog.instance.addListener(_onCatalogChanged);
    AppOptionCatalog.prefetch(force: true);
  }

  @override
  void dispose() {
    AppOptionCatalog.instance.removeListener(_onCatalogChanged);
    super.dispose();
  }

  void _onCatalogChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isTagalog = l10n.isTagalog;
    final tools = AppOptionCatalog.calmCornerTools();

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(
        title: l10n.careCalmCorner,
        onInfo: () => showCalmInfoSheet(
          context,
          CalmInfoCopy(
            whyTitle: l10n.careCalmInfoTitle,
            whyBody: l10n.careCalmInfoBody,
            howTitle: l10n.careHowToUse,
            howBody: l10n.careCalmStudentIntro,
            tipTitle: l10n.careQuickTip,
            tipBody: l10n.careBreathingTip,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.careCalmStudentIntro,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  fontSize: 14,
                ),
              ),
            ),
            if (tools.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.careCalmCornerEmpty,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: CareColors.headingOf(context).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ...tools.map((item) {
              final style = _styleFor(item.key, context);
              return CalmMenuCard(
                title: item.label(isTagalog: isTagalog),
                subtitle: _subtitleFor(item, isTagalog: isTagalog, l10n: l10n),
                icon: item.icon ?? style.icon,
                background: style.background,
                foreground: style.foreground,
                iconBackground: style.background,
                onTap: () => _openTool(context, item.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(
    AppOptionItem item, {
    required bool isTagalog,
    required AppStrings l10n,
  }) {
    final fromCatalog = item.subtitle(isTagalog: isTagalog).trim();
    if (fromCatalog.isNotEmpty) {
      return fromCatalog;
    }
    return switch (item.key) {
      'breathing' => l10n.careBreathingExerciseBody,
      'relaxing_audio' => l10n.careRelaxingAudioBody,
      'guided_meditation' => l10n.careGuidedMeditationBody,
      'visualization' => l10n.careVisualizationExercisesBody,
      'color_fun' => l10n.careColorFunBody,
      'stretch_breaks' => l10n.careStretchBreaksBody,
      _ => '',
    };
  }

  void _openTool(BuildContext context, String key) {
    final Widget? screen = switch (key) {
      'breathing' => const GuidedBreathingScreen(),
      'relaxing_audio' => const RelaxingAudioScreen(),
      'guided_meditation' => const MeditationScreen(),
      'visualization' => const VisualizationScreen(),
      'color_fun' => const ColorFunScreen(),
      'stretch_breaks' => const StretchBreaksScreen(),
      _ => null,
    };
    if (screen == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  _CalmToolStyle _styleFor(String key, BuildContext context) {
    return switch (key) {
      'breathing' => _CalmToolStyle(
          icon: Icons.air_rounded,
          background: context.pastelPanel(AppColors.softBlue),
          foreground: context.isDarkMode
              ? context.textPrimary
              : AppColors.mediumElectricBlue,
        ),
      'relaxing_audio' => _CalmToolStyle(
          icon: Icons.music_note_rounded,
          background: context.pastelPanel(AppColors.softBlue),
          foreground: context.heading,
        ),
      'guided_meditation' => _CalmToolStyle(
          icon: Icons.self_improvement_rounded,
          background: context.pastelPanel(AppColors.softPurple),
          foreground: context.isDarkMode
              ? context.textPrimary
              : AppColors.accentPurple,
        ),
      'visualization' => _CalmToolStyle(
          icon: Icons.auto_awesome_rounded,
          background: context.pastelPanel(AppColors.softRed),
          foreground: context.isDarkMode
              ? context.textPrimary
              : AppColors.fireEngineRed,
        ),
      'color_fun' => _CalmToolStyle(
          icon: Icons.palette_rounded,
          background: context.pastelPanel(AppColors.softGold),
          foreground: context.heading,
        ),
      'stretch_breaks' => _CalmToolStyle(
          icon: Icons.accessibility_new_rounded,
          background: context.pastelPanel(AppColors.softGold),
          foreground: context.heading,
        ),
      _ => _CalmToolStyle(
          icon: Icons.self_improvement_rounded,
          background: context.pastelPanel(AppColors.softBlue),
          foreground: context.heading,
        ),
    };
  }
}

class _CalmToolStyle {
  const _CalmToolStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

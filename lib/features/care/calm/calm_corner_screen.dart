import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
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

class CalmCornerScreen extends StatelessWidget {
  const CalmCornerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            CalmMenuCard(
              title: l10n.careBreathingExercise,
              subtitle: l10n.careBreathingExerciseBody,
              icon: Icons.air_rounded,
              background: context.pastelPanel(AppColors.softBlue),
              foreground: context.isDarkMode
                  ? context.textPrimary
                  : AppColors.mediumElectricBlue,
              iconBackground: context.pastelPanel(AppColors.softBlue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GuidedBreathingScreen(),
                ),
              ),
            ),
            CalmMenuCard(
              title: l10n.careRelaxingAudio,
              subtitle: l10n.careRelaxingAudioBody,
              icon: Icons.music_note_rounded,
              background: context.pastelPanel(AppColors.softBlue),
              foreground: context.heading,
              iconBackground: context.pastelPanel(AppColors.softBlue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RelaxingAudioScreen(),
                ),
              ),
            ),
            CalmMenuCard(
              title: l10n.careGuidedMeditation,
              subtitle: l10n.careGuidedMeditationBody,
              icon: Icons.self_improvement_rounded,
              background: context.pastelPanel(AppColors.softPurple),
              foreground: context.isDarkMode
                  ? context.textPrimary
                  : AppColors.accentPurple,
              iconBackground: context.pastelPanel(AppColors.softPurple),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MeditationScreen(),
                ),
              ),
            ),
            CalmMenuCard(
              title: l10n.careVisualizationExercises,
              subtitle: l10n.careVisualizationExercisesBody,
              icon: Icons.auto_awesome_rounded,
              background: context.pastelPanel(AppColors.softRed),
              foreground: context.isDarkMode
                  ? context.textPrimary
                  : AppColors.fireEngineRed,
              iconBackground: context.pastelPanel(AppColors.softRed),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VisualizationScreen(),
                ),
              ),
            ),
            CalmMenuCard(
              title: l10n.careColorFun,
              subtitle: l10n.careColorFunBody,
              icon: Icons.palette_rounded,
              background: context.pastelPanel(AppColors.softGold),
              foreground: context.heading,
              iconBackground: context.pastelPanel(AppColors.softGold),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ColorFunScreen(),
                ),
              ),
            ),
            CalmMenuCard(
              title: l10n.careStretchBreaks,
              subtitle: l10n.careStretchBreaksBody,
              icon: Icons.accessibility_new_rounded,
              background: context.pastelPanel(AppColors.softGold),
              foreground: context.heading,
              iconBackground: context.pastelPanel(AppColors.softGold),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StretchBreaksScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../care_colors.dart';
import 'audio/relaxing_audio_screen.dart';
import 'breathing/guided_breathing_screen.dart';
import 'color_fun/color_fun_screen.dart';
import 'meditation/meditation_screen.dart';
import 'stretch/stretch_breaks_screen.dart';
import 'visualization/visualization_screen.dart';
import 'widgets/calm_app_bar.dart';
import 'widgets/calm_menu_card.dart';

class CalmCornerScreen extends StatelessWidget {
  const CalmCornerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: CareColors.calmBg,
      appBar: CalmAppBar(
        title: l10n.careCalmCorner,
        onInfo: () => showCalmInfoDialog(
          context,
          title: l10n.careCalmInfoTitle,
          body: l10n.careCalmInfoBody,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            CalmMenuCard(
              title: l10n.careBreathingExercise,
              subtitle: l10n.careBreathingExerciseBody,
              icon: Icons.air_rounded,
              background: AppColors.softBlue,
              foreground: AppColors.mediumElectricBlue,
              iconBackground: AppColors.softBlue,
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
              background: AppColors.softBlue,
              foreground: AppColors.nileBlue,
              iconBackground: AppColors.softBlue,
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
              background: AppColors.softPurple,
              foreground: AppColors.accentPurple,
              iconBackground: AppColors.softPurple,
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
              background: AppColors.softRed,
              foreground: AppColors.fireEngineRed,
              iconBackground: AppColors.softRed,
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
              background: AppColors.softGold,
              foreground: AppColors.nileBlue,
              iconBackground: AppColors.softGold,
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
              background: AppColors.softGold,
              foreground: AppColors.brightGoldBorder,
              iconBackground: AppColors.softGold,
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

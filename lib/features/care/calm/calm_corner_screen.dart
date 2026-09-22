import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
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
              background: const Color(0xFFE8F8EF),
              foreground: const Color(0xFF1B7A4A),
              iconBackground: const Color(0xFFD1F0DE),
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
              background: const Color(0xFFE8F1FB),
              foreground: const Color(0xFF2B6CB0),
              iconBackground: const Color(0xFFD6E6F8),
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
              background: const Color(0xFFF3E8FF),
              foreground: const Color(0xFF7C3AED),
              iconBackground: const Color(0xFFE9D5FF),
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
              background: const Color(0xFFFCE7F3),
              foreground: const Color(0xFFDB2777),
              iconBackground: const Color(0xFFFBCFE8),
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
              background: const Color(0xFFECF4E8),
              foreground: const Color(0xFF4A7C59),
              iconBackground: const Color(0xFFD8E8D0),
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
              background: const Color(0xFFFFF7E8),
              foreground: const Color(0xFFB45309),
              iconBackground: const Color(0xFFFDE8C8),
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

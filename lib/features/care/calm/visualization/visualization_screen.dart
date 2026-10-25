import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../care_colors.dart';
import '../meditation/meditation_screen.dart' show GuidedSessionLauncher;
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_benefit_card.dart';
import '../widgets/calm_info_sheet.dart';
import '../../../../core/theme/app_theme_colors.dart';

class VisualizationScreen extends StatelessWidget {
  const VisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: CalmAppBar(
        title: l10n.careVisualizationTitle,
        onInfo: () => showCalmInfoSheet(
          context,
          CalmInfoCopy(
            whyTitle: l10n.careWhyMeditation,
            whyBody: l10n.careWhyVisualizationBody,
            howTitle: l10n.careHowToUse,
            howBody: l10n.careHowVisualizationBody,
            tipTitle: l10n.careQuickTip,
            tipBody: l10n.careVisualizationTip,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: CareColors.brandGradient,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.landscape_rounded,
                        size: 88, color: Colors.white),
                    SizedBox(height: 8),
                    Icon(Icons.pets_rounded,
                        size: 36, color: CareColors.accentGold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.carePeacefulPlace,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: CareColors.headingOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.carePeacefulPlaceBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: CareColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 18),
            CalmBenefitCard(
              heading: l10n.careInThisExercise,
              items: [
                l10n.careVizImagine,
                l10n.careVizSenses,
                l10n.careVizFeelRelaxed,
              ],
            ),
            const SizedBox(height: 24),
            CalmPrimaryButton(
              label: l10n.carePlayExercise,
              onPressed: () {
                HapticFeedback.lightImpact();
                GuidedSessionLauncher.openVisualization(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

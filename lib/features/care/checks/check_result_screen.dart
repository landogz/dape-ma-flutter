import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/care_check_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../calm_corner_screen.dart';
import '../care_colors.dart';
import '../get_support_screen.dart';
import 'check_flow_screen.dart';
import 'check_gauge.dart';
import 'widgets/check_brand_button.dart';
import 'widgets/check_disclaimer_row.dart';

class CheckResultScreen extends StatefulWidget {
  const CheckResultScreen({
    super.key,
    required this.result,
  });

  final CareCheckResult result;

  @override
  State<CheckResultScreen> createState() => _CheckResultScreenState();
}

class _CheckResultScreenState extends State<CheckResultScreen> {
  late CareCheckResult _result = widget.result;

  String _title(AppStrings l10n) {
    return switch (_result.checkType) {
      'stress' => l10n.careStressResultTitle,
      _ => l10n.careCheckResultTitle,
    };
  }

  String _levelLabel(AppStrings l10n) {
    return switch (_result.checkType) {
      'stress' => l10n.careYourStressLevel,
      'anxiety' => l10n.careYourAnxietyLevel,
      _ => l10n.careYourSleepQuality,
    };
  }

  String _band(AppStrings l10n) {
    final high = _result.isHighTier;
    return switch (_result.checkType) {
      'stress' => high ? l10n.careBandStressHigh : l10n.careBandStressLow,
      'anxiety' => high ? l10n.careBandAnxietyHigh : l10n.careBandAnxietyLow,
      _ => high ? l10n.careBandSleepHigh : l10n.careBandSleepLow,
    };
  }

  String _headline(AppStrings l10n) {
    final high = _result.isHighTier;
    return switch (_result.checkType) {
      'stress' => high ? l10n.careStressHighHeadline : l10n.careStressLowHeadline,
      'anxiety' =>
        high ? l10n.careAnxietyHighHeadline : l10n.careAnxietyLowHeadline,
      _ => high ? l10n.careSleepHighHeadline : l10n.careSleepLowHeadline,
    };
  }

  String _body(AppStrings l10n) {
    final high = _result.isHighTier;
    return switch (_result.checkType) {
      'stress' => high ? l10n.careStressHighBody : l10n.careStressLowBody,
      'anxiety' => high ? l10n.careAnxietyHighBody : l10n.careAnxietyLowBody,
      _ => high ? l10n.careSleepHighBody : l10n.careSleepLowBody,
    };
  }

  Future<void> _retake() async {
    final next = await Navigator.of(context).push<CareCheckResult>(
      MaterialPageRoute(
        builder: (_) => CheckFlowScreen(checkType: _result.checkType),
      ),
    );
    if (next != null && mounted) {
      setState(() => _result = next);
    }
  }

  void _primary() {
    if (_result.isHighTier) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GetSupportScreen()),
      );
      return;
    }
    if (_result.checkType == 'sleep') {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CalmCornerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final high = _result.isHighTier;
    final bandColor = high ? AppColors.fireEngineRed : CareColors.headingOf(context);
    final bandFill = high
        ? AppColors.fireEngineRed.withValues(alpha: context.isDarkMode ? 0.22 : 0.10)
        : CareColors.mintOf(context);
    final isSleep = _result.checkType == 'sleep';
    final primaryLabel = high
        ? l10n.careGetSupportTitle
        : (isSleep ? l10n.careBackToToolkit : l10n.careGoToCalmCorner);

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: CareColors.headingOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          _title(l10n),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: CareColors.headingOf(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  decoration: BoxDecoration(
                    color: context.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: CareColors.cardBorderOf(context)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.nileBlue.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CareColors.mintOf(context),
                        ),
                        child: isSleep
                            ? Text(
                                high ? '😥' : '😄',
                                style: const TextStyle(fontSize: 72),
                              )
                            : FittedBox(
                                child: CheckGauge(highTier: high),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _levelLabel(l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: bandFill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: high
                                ? AppColors.fireEngineRedBorder
                                : CareColors.cardBorderOf(context),
                          ),
                        ),
                        child: Text(
                          _band(l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: bandColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    color: context.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CareColors.cardBorderOf(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _headline(l10n),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: CareColors.headingOf(context),
                          fontSize: 17,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _body(l10n),
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CheckDisclaimerRow(text: l10n.careCheckDisclaimer),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  CheckBrandButton(label: primaryLabel, onPressed: _primary),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _retake,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: CareColors.headingOf(context),
                        side: BorderSide(
                          color: CareColors.headingOf(context),
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        l10n.careRetakeAssessment,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final isSleep = _result.checkType == 'sleep';
    final primaryLabel = high
        ? l10n.careGetSupportTitle
        : (isSleep ? l10n.careBackToToolkit : l10n.careGoToCalmCorner);

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: AppBar(
        backgroundColor: CareColors.pageBgOf(context),
        foregroundColor: CareColors.headingOf(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _title(l10n),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: CareColors.headingOf(context),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: isSleep
                  ? Text(
                      high ? '😥' : '😄',
                      style: const TextStyle(fontSize: 88),
                    )
                  : CheckGauge(highTier: high),
            ),
            const SizedBox(height: 8),
            Text(
              _levelLabel(l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: CareColors.headingOf(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _band(l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: bandColor,
                fontSize: 26,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _headline(l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: CareColors.textOf(context),
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _body(l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CareColors.mintOf(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco_rounded, color: CareColors.headingOf(context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.careCheckDisclaimer,
                      style: TextStyle(
                        color: CareColors.textOf(context),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _BrandButton(label: primaryLabel, onPressed: _primary),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _retake,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: CareColors.headingOf(context),
                  side: BorderSide(color: CareColors.headingOf(context), width: 1.4),
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
    );
  }
}

class _BrandButton extends StatelessWidget {
  const _BrandButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

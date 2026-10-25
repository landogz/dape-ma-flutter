import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../care_colors.dart';
import 'check_brand_button.dart';
import 'check_disclaimer_row.dart';
import 'check_type_icon.dart';

class CheckIntroView extends StatelessWidget {
  const CheckIntroView({
    super.key,
    required this.checkType,
    required this.body,
    required this.minutes,
    required this.disclaimer,
    required this.cta,
    required this.onStart,
  });

  final String checkType;
  final String body;
  final String minutes;
  final String disclaimer;
  final String cta;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              const SizedBox(height: 12),
              Center(child: CheckTypeIcon(checkType: checkType)),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.brightGold.withValues(alpha: 0.16)
                        : AppColors.softGold,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.brightGoldBorder),
                  ),
                  child: Text(
                    minutes,
                    style: TextStyle(
                      color: CareColors.headingOf(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CareColors.cardBorderOf(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.nileBlue.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 5,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Text(
                            body,
                            style: TextStyle(
                              color: CareColors.textOf(context),
                              height: 1.5,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CheckDisclaimerRow(text: disclaimer),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: CheckBrandButton(label: cta, onPressed: onStart),
          ),
        ),
      ],
    );
  }
}

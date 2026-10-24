import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import 'legal_document_screen.dart';

class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LegalDocumentScreen(
      slug: 'privacy_notice',
      fallbackTitle: l10n.privacyNotice,
      fallbackIntro: l10n.privacyNoticeIntro,
      fallbackBody: l10n.privacyNoticeBody,
      icon: Icons.policy_rounded,
      iconBackground: context.isDarkMode
          ? const Color(0xFF422006)
          : const Color(0xFFFEF9C3),
      iconColor: context.isDarkMode
          ? const Color(0xFFFDE047)
          : AppColors.nileBlue,
    );
  }
}

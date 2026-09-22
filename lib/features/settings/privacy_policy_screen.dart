import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LegalDocumentScreen(
      slug: 'privacy_policy',
      fallbackTitle: l10n.privacyPolicy,
      fallbackIntro: l10n.privacyIntro,
      fallbackBody: l10n.privacyBody,
      icon: Icons.shield_rounded,
      iconBackground: const Color(0xFFDCFCE7),
    );
  }
}

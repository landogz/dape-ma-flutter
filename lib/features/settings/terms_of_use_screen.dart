import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import 'legal_document_screen.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LegalDocumentScreen(
      slug: 'terms_of_use',
      fallbackTitle: l10n.termsOfUse,
      fallbackIntro: '${l10n.termsIntro}\n${l10n.termsSubtitle}',
      fallbackBody: l10n.termsBody,
      icon: Icons.description_rounded,
      iconBackground: const Color(0xFFE0F2FE),
    );
  }
}

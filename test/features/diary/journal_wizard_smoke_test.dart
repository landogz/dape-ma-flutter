import 'package:dape_ma_mobile/core/l10n/app_locale.dart';
import 'package:dape_ma_mobile/core/l10n/locale_controller.dart';
import 'package:dape_ma_mobile/core/l10n/locale_scope.dart';
import 'package:dape_ma_mobile/features/diary/widgets/journal_wizard/journal_wizard_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('journal wizard renders 4 steps chrome', (tester) async {
    final controller = LocaleController.instance;
    await controller.setLocale(AppLocale.en);

    await tester.pumpWidget(
      LocaleScope(
        controller: controller,
        child: const MaterialApp(
          home: Scaffold(
            body: JournalWizardSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('OF 4'), findsOneWidget);
    expect(find.text("How's your sky today?"), findsOneWidget);
    expect(find.text('Clear Skies'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Clear Skies'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('What are you feeling?'), findsOneWidget);
    expect(find.text('Grateful'), findsOneWidget);
  });
}

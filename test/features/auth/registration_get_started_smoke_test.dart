import 'package:dape_ma_mobile/core/l10n/app_locale.dart';
import 'package:dape_ma_mobile/core/l10n/locale_controller.dart';
import 'package:dape_ma_mobile/core/l10n/locale_scope.dart';
import 'package:dape_ma_mobile/features/auth/registration/steps/get_started_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('get started step shows DAPE-MA copy and continue', (tester) async {
    final controller = LocaleController.instance;
    await controller.setLocale(AppLocale.en);

    await tester.pumpWidget(
      LocaleScope(
        controller: controller,
        child: MaterialApp(
          home: Scaffold(
            body: GetStartedStep(
              loading: false,
              onContinue: ({
                required email,
                required password,
                required passwordConfirmation,
              }) async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.textContaining('DAPE-MA journey'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}

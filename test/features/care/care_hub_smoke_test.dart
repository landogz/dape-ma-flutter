import 'package:dape_ma_mobile/core/l10n/app_locale.dart';
import 'package:dape_ma_mobile/core/l10n/locale_controller.dart';
import 'package:dape_ma_mobile/core/l10n/locale_scope.dart';
import 'package:dape_ma_mobile/features/care/calm_corner_screen.dart';
import 'package:dape_ma_mobile/features/care/care_hub_screen.dart';
import 'package:dape_ma_mobile/features/care/get_support_screen.dart';
import 'package:dape_ma_mobile/features/care/self_care_toolkit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpWithLocale(WidgetTester tester, Widget child) async {
  final controller = LocaleController.instance;
  await controller.setLocale(AppLocale.en);
  await tester.pumpWidget(
    LocaleScope(
      controller: controller,
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  testWidgets('Care hub shows DAPE Care branding and speed dial', (tester) async {
    await _pumpWithLocale(tester, const CareHubScreen());
    await tester.pump(); // first frame
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('DAPE Care'), findsWidgets);
    expect(find.text('Speed Dial'), findsOneWidget);
    expect(find.text('My Journal'), findsOneWidget);
    expect(find.text('Self-Care Toolkit'), findsOneWidget);
    expect(find.text('Get Support'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Calm Corner'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Calm Corner'), findsOneWidget);
  });

  testWidgets('Toolkit and support screens render', (tester) async {
    await _pumpWithLocale(tester, const SelfCareToolkitScreen());
    await tester.pumpAndSettle();
    expect(find.text('Stress Check'), findsOneWidget);

    await _pumpWithLocale(tester, const GetSupportScreen());
    await tester.pumpAndSettle();
    expect(find.text('24/7 Hotlines'), findsOneWidget);
    expect(find.text('Crisis Support'), findsOneWidget);

    await _pumpWithLocale(tester, const CalmCornerScreen());
    await tester.pumpAndSettle();
    expect(find.text('Calm Corner'), findsWidgets);
  });
}

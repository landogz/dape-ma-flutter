import 'package:dape_ma_mobile/core/l10n/app_locale.dart';
import 'package:dape_ma_mobile/core/l10n/locale_controller.dart';
import 'package:dape_ma_mobile/core/l10n/locale_scope.dart';
import 'package:dape_ma_mobile/features/home/widgets/home_header.dart';
import 'package:dape_ma_mobile/features/home/widgets/thought_of_day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home header and thought card render DAPE-MA copy', (tester) async {
    final controller = LocaleController.instance;
    await controller.setLocale(AppLocale.en);

    await tester.pumpWidget(
      LocaleScope(
        controller: controller,
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                HomeHeader(
                  greetingName: 'Hi, Alex!',
                  subtitle: 'What do you like to explore today?',
                  unreadNotifications: 0,
                  onNotificationTap: _noop,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ThoughtOfDayBanner(
                    message: 'Small steps every day lead to a better you.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hi, Alex!'), findsOneWidget);
    expect(find.textContaining('Thought of the Day'), findsOneWidget);
    expect(find.textContaining('Small steps'), findsOneWidget);
  });
}

void _noop() {}

import 'package:flutter/widgets.dart';

import 'app_strings.dart';
import 'locale_controller.dart';

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();

    return scope?.notifier ?? LocaleController.instance;
  }

  static AppStrings strings(BuildContext context) {
    return AppStrings(of(context).locale);
  }
}

extension AppLocalizationsX on BuildContext {
  AppStrings get l10n => LocaleScope.strings(this);
}

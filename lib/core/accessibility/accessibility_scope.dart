import 'package:flutter/widgets.dart';

import 'accessibility_controller.dart';

class AccessibilityScope extends InheritedNotifier<AccessibilityController> {
  const AccessibilityScope({
    super.key,
    required AccessibilityController controller,
    required super.child,
  }) : super(notifier: controller);

  static AccessibilityController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AccessibilityScope>();
    assert(scope != null, 'AccessibilityScope not found in widget tree');
    return scope!.notifier!;
  }

  static AccessibilityController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AccessibilityScope>()
        ?.notifier;
  }
}

extension AccessibilityContext on BuildContext {
  AccessibilityController get accessibility => AccessibilityScope.of(this);
}

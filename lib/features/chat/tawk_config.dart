/// Tawk.to live chat for the FAQ tab.
///
/// Uses the full chat page (not the floating bubble widget).
class TawkConfig {
  TawkConfig._();

  /// Property / widget path from the Tawk embed script.
  static const String propertyId = '6ac0df3a99bc2b34c466645e';
  static const String widgetId = '1k40mfvv2';

  /// Full-page chat UI — open this directly in the FAQ WebView.
  static const String directChatUrl =
      'https://tawk.to/chat/$propertyId/$widgetId';

  static const String externalChatUrl = directChatUrl;

  static bool get isConfigured =>
      propertyId.isNotEmpty && widgetId.isNotEmpty;
}

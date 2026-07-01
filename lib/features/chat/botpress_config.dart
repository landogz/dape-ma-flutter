/// Botpress Webchat embedded configuration (Dangerous Drugs Board bot).
class BotpressConfig {
  BotpressConfig._();

  static const String botId = 'd636e6f3-323d-46ad-8c08-b44c2bf170c7';

  static const String workspaceId = 'wkspace_01KWF7CWKFFRBWHA1AQ782EN18';

  /// Must match Botpress Deploy Settings → Embedded → Element ID.
  static const String elementId = 'bp-embedded-webchat';

  static const String injectScriptUrl =
      'https://cdn.botpress.cloud/webchat/v3.6/inject.js';

  static const String configScriptUrl =
      'https://files.bpcontent.cloud/2026/07/01/16/20260701161618-5PW46XBP.js';

  static bool get isConfigured =>
      botId.isNotEmpty && configScriptUrl.isNotEmpty;

  static String buildEmbedHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #ffffff;
    }
    #$elementId {
      position: relative;
      width: 100%;
      height: 100%;
      min-height: 100vh;
    }
    .bpFab { display: none !important; }
    .bpWebchat {
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      bottom: 0 !important;
      width: 100% !important;
      height: 100% !important;
      max-height: 100% !important;
    }
  </style>
  <script src="$injectScriptUrl"></script>
  <script src="$configScriptUrl" defer></script>
</head>
<body>
  <div id="$elementId"></div>
  <script>
    window.botpress.on('webchat:initialized', function () {
      window.botpress.open();
    });
  </script>
</body>
</html>
''';
  }
}

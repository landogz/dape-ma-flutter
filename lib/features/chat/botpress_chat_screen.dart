import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/locale_scope.dart';
import 'botpress_config.dart';

class BotpressChatScreen extends StatefulWidget {
  const BotpressChatScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<BotpressChatScreen> createState() => _BotpressChatScreenState();
}

class _BotpressChatScreenState extends State<BotpressChatScreen> {
  InAppWebViewController? _webViewController;
  bool _loadFailed = false;
  bool _isDisposed = false;

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(BotpressConfig.externalChatUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open browser')),
      );
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _webViewController?.stopLoading();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = context.l10n.navFaq;
    if (!BotpressConfig.isConfigured) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: !widget.embeddedInShell,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.settings_suggest_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Botpress is not configured yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your config script URL from Botpress → Webchat → Deploy Settings to lib/features/chat/botpress_config.dart.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !widget.embeddedInShell,
        actions: [
          IconButton(
            onPressed: _openInBrowser,
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: SafeArea(
        bottom: !widget.embeddedInShell,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.embeddedInShell ? 88 : 0),
          child: Stack(
          children: [
            InAppWebView(
              key: const ValueKey('botpress_chat_webview'),
              initialData: InAppWebViewInitialData(
                data: BotpressConfig.buildEmbedHtml(),
                baseUrl: WebUri(BotpressConfig.webViewBaseUrl),
                mimeType: 'text/html',
                encoding: 'utf-8',
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                cacheEnabled: true,
                useOnLoadResource: false,
                mediaPlaybackRequiresUserGesture: false,
                transparentBackground: true,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onReceivedError: (controller, request, error) {
                final isMainFrame = request.isForMainFrame ?? false;
                if (isMainFrame) {
                  _safeSetState(() => _loadFailed = true);
                }
              },
              onLoadStop: (controller, url) {
                _safeSetState(() => _loadFailed = false);
              },
            ),
            if (_loadFailed)
              ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load chat in the app.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Open live chat in your browser instead.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _openInBrowser,
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open in browser'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          _safeSetState(() => _loadFailed = false);
                          _webViewController?.loadData(
                            data: BotpressConfig.buildEmbedHtml(),
                            baseUrl: WebUri(BotpressConfig.webViewBaseUrl),
                            mimeType: 'text/html',
                            encoding: 'utf-8',
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

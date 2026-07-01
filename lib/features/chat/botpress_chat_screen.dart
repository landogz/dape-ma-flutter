import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'botpress_config.dart';

class BotpressChatScreen extends StatefulWidget {
  const BotpressChatScreen({super.key});

  @override
  State<BotpressChatScreen> createState() => _BotpressChatScreenState();
}

class _BotpressChatScreenState extends State<BotpressChatScreen> {
  InAppWebViewController? _webViewController;
  bool _loadFailed = false;
  bool _isDisposed = false;

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
    if (!BotpressConfig.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Chat')),
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
      appBar: AppBar(title: const Text('Live Chat')),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: const ValueKey('botpress_chat_webview'),
              initialData: InAppWebViewInitialData(
                data: BotpressConfig.buildEmbedHtml(),
                baseUrl: WebUri('https://cdn.botpress.cloud'),
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
                        'Check your Botpress config script URL and try again.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          _safeSetState(() => _loadFailed = false);
                          _webViewController?.loadData(
                            data: BotpressConfig.buildEmbedHtml(),
                            baseUrl: WebUri('https://cdn.botpress.cloud'),
                            mimeType: 'text/html',
                            encoding: 'utf-8',
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

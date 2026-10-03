import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_app_bar/brand_app_bar.dart';
import 'tawk_config.dart';

class TawkChatScreen extends StatefulWidget {
  const TawkChatScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<TawkChatScreen> createState() => _TawkChatScreenState();
}

class _TawkChatScreenState extends State<TawkChatScreen> {
  InAppWebViewController? _webViewController;
  bool _loadFailed = false;
  bool _isDisposed = false;

  WebUri get _chatUri => WebUri(TawkConfig.directChatUrl);

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(TawkConfig.externalChatUrl);
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

  Future<void> _reloadChat() async {
    _safeSetState(() => _loadFailed = false);
    await _webViewController?.loadUrl(urlRequest: URLRequest(url: _chatUri));
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

    if (!TawkConfig.isConfigured) {
      return Scaffold(
        appBar: BrandAppBar(
          title: title,
          automaticallyImplyLeading: !widget.embeddedInShell,
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Live chat is not configured yet.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BrandAppBar(
        title: title,
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
                key: const ValueKey('tawk_chat_page_webview'),
                initialUrlRequest: URLRequest(url: _chatUri),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  cacheEnabled: true,
                  useOnLoadResource: false,
                  mediaPlaybackRequiresUserGesture: false,
                  transparentBackground: false,
                  allowsInlineMediaPlayback: true,
                  supportMultipleWindows: true,
                  javaScriptCanOpenWindowsAutomatically: true,
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
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  if (uri == null) return NavigationActionPolicy.ALLOW;
                  final host = uri.host.toLowerCase();
                  if (host.contains('tawk.to') ||
                      host.contains('googleapis.com') ||
                      host.isEmpty) {
                    return NavigationActionPolicy.ALLOW;
                  }
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  return NavigationActionPolicy.CANCEL;
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _openInBrowser,
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open in browser'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mediumElectricBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _reloadChat,
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

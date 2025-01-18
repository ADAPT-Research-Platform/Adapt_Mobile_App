import 'package:adapt/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/app_keys.dart';
import '../widgets/main_title.dart';

class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  final log = Logger('ConsentPage');
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize WebViewController with required settings
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            log.info('Page started loading: $url');
          },
          onPageFinished: (url) {
            log.info('Page finished loading: $url');
          },
          onWebResourceError: (error) {
            log.severe('Error loading page: $error');
          },
        ),
      )
      ..loadRequest(Uri.parse('${AppConfig.baseUrl}/uploads/pages/consent.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(
          title: 'Consent',
          leadingIcon: Icons.arrow_back_ios_rounded,
          onIconPressed: () {
            mainNavigator.currentState!.pop(); //Go Backwards
          }),
      body: WebViewWidget(controller: _controller) // Display the WebView
    );
  }
}

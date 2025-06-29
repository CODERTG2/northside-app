// lib/widgets/webview_sheet.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/utils/logger.dart';

class WebViewSheet extends StatefulWidget {
  const WebViewSheet({super.key, required this.url});
  final String url;

  @override
  State<WebViewSheet> createState() => _WebViewSheetState();
}

class _WebViewSheetState extends State<WebViewSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // This line is for native mobile apps (iOS/Android) and enables JavaScript.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // This delegate is for native mobile apps to show a loading indicator.
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
            AppLogger.debug('Webview Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar devices
    
    // Get safe area padding to respect notch/status bar
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    // Adaptive sizing based on screen dimensions
    final double initialChildSize = isNarrowScreen ? 0.85 : 0.9;
    final double minChildSize = isNarrowScreen ? 0.4 : 0.5;
    final double maxChildSize = isNarrowScreen ? 0.85 : 0.9;
    
    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Use a Stack to show a loading indicator over the WebView
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    // This loading indicator will show on mobile but not in the web preview
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}

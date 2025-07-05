// lib/widgets/webview_sheet.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../core/utils/logger.dart';

class WebViewSheet extends StatefulWidget {
  const WebViewSheet({super.key, required this.url});
  final String url;

  @override
  State<WebViewSheet> createState() => _WebViewSheetState();
}

class _WebViewSheetState extends State<WebViewSheet> 
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller with iOS-style duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly longer for more gradual feel
      vsync: this,
    );

    // Create more gradual iOS-style animation with custom curve
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn, // More gradual deceleration than easeOut
    );

    // Start the animation when the sheet is created
    _animationController.forward();
    
    _controller = WebViewController()
      // This line is for native mobile apps (iOS/Android) and enables JavaScript.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // This delegate is for native mobile apps to show a loading indicator.
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            AppLogger.debug('Webview Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    // Clean up the WebView controller and animation when the widget is disposed
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchInExternalBrowser() async {
    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.warning('Could not launch URL: ${widget.url}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open link in external browser'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error launching URL in external browser', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening link in external browser'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * MediaQuery.of(context).size.height),
          child: Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              minChildSize: minChildSize,
              maxChildSize: maxChildSize,
              builder: (_, controller) {
                return Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF2F2F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1.0),
                        topRight: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1.0),
                      ),
                    ),
                    shadows: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 60, offset: const Offset(0, 10), spreadRadius: 0)],
                  ),
                  child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: Colors.grey.shade300,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    // Header with external browser button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Web View',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _launchInExternalBrowser,
                            icon: const Icon(Icons.open_in_new),
                            tooltip: 'Open in external browser',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ],
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
          ),
        );
      },
    );
  }
}

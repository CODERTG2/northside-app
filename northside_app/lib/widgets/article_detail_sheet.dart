// lib/widgets/article_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

import '../models/article.dart';
import 'webview_sheet.dart';

class ArticleDetailSheet extends StatelessWidget {
  const ArticleDetailSheet({super.key, required this.article, this.scrollController});
  final ScrollController? scrollController;
  final Article article;

  // Helper method to parse simple markdown links [text](url)
  Widget _buildContentWithLinks(String content) {
    final linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(content);
    
    if (matches.isEmpty) {
      // No links found, return plain text
      return Text(
        content,
        style: const TextStyle(fontSize: 16, height: 1.5),
      );
    }
    
    List<TextSpan> spans = [];
    int lastEnd = 0;
    
    for (final match in matches) {
      // Add text before the link
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
        ));
      }
      
      // Add the link
      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;
      
      spans.add(TextSpan(
        text: linkText,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Get.bottomSheet(
              WebViewSheet(url: linkUrl),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useRootNavigator: false,
              enableDrag: true,
            );
          },
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text after the last link
    if (lastEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastEnd),
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This container gives the sheet its shape and background color.
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
          // Scrollable content area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                // Conditionally display the image if it exists
                if (article.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(article.imagePath!, fit: BoxFit.contain),
                    ),
                  ),
                // Title
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Main content with link support
                _buildContentWithLinks(article.content),
                const SizedBox(height: 40), // Extra space at the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}

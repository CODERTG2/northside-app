// lib/widgets/article_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';

class ArticleDetailSheet extends StatelessWidget {
  const ArticleDetailSheet({super.key, required this.article, this.scrollController});
  final ScrollController? scrollController;
  final Article article;

  // Helper method to build clickable text with URLs
  Widget _buildClickableText(String text) {
    final RegExp urlRegExp = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    
    final List<TextSpan> spans = [];
    final List<RegExpMatch> matches = urlRegExp.allMatches(text).toList();
    
    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
      );
    }
    
    int lastEnd = 0;
    
    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
        ));
      }
      
      // Add the clickable URL
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text after the last URL
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
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
                // Main content with clickable URLs
                _buildClickableText(article.content),
                const SizedBox(height: 40), // Extra space at the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}

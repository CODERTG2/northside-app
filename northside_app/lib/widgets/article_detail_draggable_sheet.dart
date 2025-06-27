import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_detail_sheet.dart';

class ArticleDetailDraggableSheet extends StatelessWidget {
  final Article article;
  const ArticleDetailDraggableSheet({super.key, required this.article});

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
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ArticleDetailSheet(
              article: article,
              scrollController: scrollController,
            ),
          );
        },
      ),
    );
  }
}
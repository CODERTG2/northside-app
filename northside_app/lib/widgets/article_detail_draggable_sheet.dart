import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../models/article.dart';
import '../core/design_constants.dart';
import 'article_detail_sheet.dart';

class ArticleDetailDraggableSheet extends StatefulWidget {
  final Article article;
  const ArticleDetailDraggableSheet({super.key, required this.article});

  @override
  State<ArticleDetailDraggableSheet> createState() => _ArticleDetailDraggableSheetState();
}

class _ArticleDetailDraggableSheetState extends State<ArticleDetailDraggableSheet>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF2F2F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                        topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                      ),
                    ),
                    shadows: DesignConstants.standardShadow,
                  ),
                  child: ArticleDetailSheet(
                    article: widget.article,
                    scrollController: scrollController,
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
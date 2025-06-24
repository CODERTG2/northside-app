import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_detail_sheet.dart';

class ArticleDetailDraggableSheet extends StatelessWidget {
  final Article article;
  const ArticleDetailDraggableSheet({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: true,
            left: false,
            right: false,
            bottom: false,
            child: ArticleDetailSheet(
              article: article,
              scrollController: scrollController,
            ),
          ),
        );
      },
    );
  }
}

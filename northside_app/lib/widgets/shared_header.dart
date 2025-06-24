// lib/widgets/shared_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../presentation/app_shell/app_shell_controller.dart';

class SharedHeader extends StatelessWidget {
  const SharedHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppShellController appShellController = Get.find();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth * 0.07; // Responsive title size

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: MediaQuery.of(context).padding.top + 4, // Only a small extra gap after status bar
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: -1.2, // Even tighter tracking for extra bold impact
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () {
              appShellController.changePage(4);
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

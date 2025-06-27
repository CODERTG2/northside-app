// lib/core/utils/text_helper.dart

import 'package:flutter/material.dart';

/// A utility class to handle text properly across different screen sizes
/// Particularly helpful for screens like the Samsung Galaxy S9 with different aspect ratios
class TextHelper {
  /// Returns an appropriate font size multiplier based on screen width
  /// Scales down for narrower screens to prevent overflow
  static double getFontSizeMultiplier(BuildContext context, {
    double defaultMultiplier = 0.045,
    double narrowScreenMultiplier = 0.04,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? narrowScreenMultiplier : defaultMultiplier;
  }
  
  /// Creates a responsive text widget that handles overflow properly
  /// and adjusts size based on screen dimensions
  static Widget responsiveText(
    String text, {
    required BuildContext context,
    bool isBold = false,
    bool isTitle = false,
    Color? color,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    double? customSizeMultiplier,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    
    // Base multiplier adjusted for screen size
    double multiplier;
    if (customSizeMultiplier != null) {
      multiplier = isNarrowScreen 
          ? customSizeMultiplier * 0.9  // Scale down for narrow screens
          : customSizeMultiplier;
    } else if (isTitle) {
      multiplier = isNarrowScreen ? 0.05 : 0.055;
    } else {
      multiplier = isNarrowScreen ? 0.037 : 0.042;
    }
    
    final double fontSize = screenWidth * multiplier;
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
  
  /// Creates a FittedBox text that scales to fit its container
  /// Perfect for headers that should never overflow
  static Widget fittedText(
    String text, {
    required BuildContext context,
    bool isBold = false,
    Color? color,
    double? customSizeMultiplier,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double multiplier = customSizeMultiplier ?? 0.055;
    final double fontSize = screenWidth * multiplier;
    
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Design constants for consistent UI across all screen sizes
/// Proportions are based on iPhone 16 Pro Max (430pt width) for optimal visual consistency
class DesignConstants {
  /// Base reference width (iPhone 16 Pro Max)
  static const double _baseWidth = 430.0;
  
  /// Get responsive radius based on screen width
  static double getResponsiveRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (baseRadius / _baseWidth) * screenWidth;
  }
  
  /// Card radius constants (proportional to screen width)
  static double getRegularCardRadius(BuildContext context) => getResponsiveRadius(context, 24.0);
  static double getCarouselCardRadius(BuildContext context) => getResponsiveRadius(context, 32.0);
  static double getTabButtonRadius(BuildContext context) => getResponsiveRadius(context, 28.0);
  static double getSmallCardRadius(BuildContext context) => getResponsiveRadius(context, 20.0);
  static double getButtonRadius(BuildContext context) => getResponsiveRadius(context, 16.0);
  static double getSmallButtonRadius(BuildContext context) => getResponsiveRadius(context, 10.0);
  
  /// Convenience methods for common use cases
  static double get24Radius(BuildContext context) => getRegularCardRadius(context);
  static double get32Radius(BuildContext context) => getCarouselCardRadius(context);
  static double get28Radius(BuildContext context) => getTabButtonRadius(context);
  static double get20Radius(BuildContext context) => getSmallCardRadius(context);
  static double get16Radius(BuildContext context) => getButtonRadius(context);
  static double get10Radius(BuildContext context) => getSmallButtonRadius(context);
  
  /// iOS-style shadow constants
  static List<BoxShadow> get standardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 60,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    )
  ];
  
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    )
  ];
  
  // Bulletin-specific shadow (lighter for date headers)
  static List<BoxShadow> get bulletinShadow => lightShadow;
}

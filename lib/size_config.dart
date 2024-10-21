import 'package:flutter/widgets.dart';

const double KDesignScreenWidth = 375.0;  // Reference design width
const double KDesignScreenHeight = 667.0; // Reference design height
const double KDesignScreenHeightLg = 768.0; // For larger devices

/// This function calculates the available safe area size by accounting for
/// screen insets (like status bar, navigation bar) and adjusting for keyboard view insets.
Size getSafeAreaSize(MediaQueryData mediaQD) {
  final screenWidth = mediaQD.size.width;
  final screenHeight = mediaQD.size.height;

  final statusBarHeight = mediaQD.padding.top;
  final bottomSpacing = mediaQD.padding.bottom;

  // EdgeInsets for things like the keyboard
  final edgeInsets = mediaQD.viewInsets;

  // Subtract view insets and paddings from available screen height and width
  return Size(
    screenWidth - edgeInsets.left - edgeInsets.right,
    screenHeight - statusBarHeight - bottomSpacing - edgeInsets.top - edgeInsets.bottom,
  );
}

/// This function calculates responsive width based on the reference design width.
double getDeviceExactWidth(double sizeInDesign, Size safeAreaSize) {
  return (sizeInDesign / KDesignScreenWidth) * safeAreaSize.width;
}

/// This function calculates responsive height based on the reference design height,
/// choosing a large screen height for larger devices.
double getDeviceExactHeight(double sizeInDesign, Size safeAreaSize) {
  var isXSSize = safeAreaSize.height > 800;  // Detect large screens
  if (isXSSize) {
    return (sizeInDesign / KDesignScreenHeightLg) * safeAreaSize.height;
  }
  return (sizeInDesign / KDesignScreenHeight) * safeAreaSize.height;
}

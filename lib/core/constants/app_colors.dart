// appColors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(
    0xFF156EF5,
  ); // Main blue (buttons, FAB, highlights)
  static const Color background = Color(0xFFF8F9FC); // Very light background
  static const Color card = Color(0xFFFFFFFF); // Card white
  static const Color border = Color(0xFFE5E6E9); // Card, container borders

  static const Color icon = Color(0xFF202337); // Icon/text dark
  static const Color secondaryText = Color(0xFF737A96); // Subtext gray

  static const Color chipBlue = Color(0xFFEDF4FF); // Selected tab/chip blue
  static const Color chipGray = Color(0xFFF0F1F3); // Unselected chip/tab gray

  static const Color success = Color(
    0xFF30B177,
  ); // Green for "Paid", positive chips
  static const Color warning = Color(0xFFFFC247); // Yellow for "Pending"
  static const Color error = Color(0xFFF87171); // Red for high priority/error
  static const Color info = Color(0xFF7AC6F0); // Teal/Blue info highlight

  static const Color disabled = Color(
    0xFFEEF0F4,
  ); // Form field/disabled backgrounds

  static const Color star = Color(0xFFFFC700); // Rating stars

  // For dark/shadow effects (if needed):
  static const Color shadow = Color(0x1A293149);

  // Added to support existing auth screens
  static const Color accent = primary;
  static const Color inputFill = Color(0xFFF3F5F9);
  static const Color scaffoldBackground = Color(0xFFf6f6f6);
  static const Color textSecondary = Color(0xFF9AA0B4);
}

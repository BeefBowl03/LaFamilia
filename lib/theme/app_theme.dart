import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5E72E4); // Deep blue
  static const Color secondaryColor = Color(0xFF11CDEF); // Cyan
  static const Color accentColor = Color(0xFFFB6340); // Orange
  static const Color successColor = Color(0xFF2DCE89); // Green
  static const Color warningColor = Color(0xFFFFBB33); // Amber
  static const Color dangerColor = Color(0xFFF5365C); // Red
  static const Color backgroundLight = Color(0xFFF8F9FE); // Light grey
  static const Color backgroundDark = Color(0xFF1A1B2A); // Dark blue-grey
  static const Color textLight = Color(0xFF8898AA); // Medium grey
  static const Color textDark = Color(0xFF525F7F); // Dark grey

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData.light().textTheme.copyWith(
        displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textLight.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textLight.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white;
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: textLight.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.white),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundDark.withOpacity(0.8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryColor,
        side: const BorderSide(color: secondaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundDark.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white.withOpacity(0.1);
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundDark,
      selectedItemColor: secondaryColor,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
      space: 24,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}
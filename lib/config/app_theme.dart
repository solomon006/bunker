import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Цвета в стиле постапокалиптического дизайна
  static const Color primaryBackground = Color(0xFFD9D0C3); // Бумажный беж
  static const Color secondaryBackground = Color(0xFFE8E4D9); // Светлый беж
  static const Color cardColor = Color(0xFFCFC1A9); // Песочный
  static const Color accentColor = Color(0xFF8C7356); // Коричневый
  static const Color darkAccentColor = Color(0xFF5E4E36); // Темно-коричневый
  static const Color textColor = Color(0xFF292018); // Почти черный
  static const Color yellowAccent = Color(0xFFF3D250); // Желтый акцент
  static const Color redAccent = Color(0xFFCD5C5C); // Красный акцент
  static const Color greenAccent = Color(0xFF689F38); // Зеленый акцент
  static const Color blueAccent = Color(0xFF5C6BC0); // Синий акцент

  // Светлая тема
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: accentColor,
      scaffoldBackgroundColor: primaryBackground,
      cardColor: cardColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: darkAccentColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surface: cardColor,
        onSurface: textColor,
        background: primaryBackground,
        onBackground: textColor,
      ),
      textTheme: GoogleFonts.rubikTextTheme().copyWith(
        displayLarge: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(color: textColor),
        titleLarge: const TextStyle(color: textColor, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textColor),
        bodyMedium: const TextStyle(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Темная тема
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: darkAccentColor,
      scaffoldBackgroundColor: Colors.grey[900],
      cardColor: Colors.grey[800],
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: yellowAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        surface: Colors.grey[800]!,
        onSurface: Colors.white,
        background: Colors.grey[900]!,
        onBackground: Colors.white,
      ),
      textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.grey[300]),
        titleLarge: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.grey[300]),
        bodyMedium: TextStyle(color: Colors.grey[400]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: yellowAccent,
          side: BorderSide(color: yellowAccent),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[800],
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

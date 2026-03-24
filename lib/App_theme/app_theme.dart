import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffF5F6FA),
    primaryColor: const Color(0xFF6C63FF),
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade200,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFF7C6FFF),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xffF5F6FA),
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    // ✅ Add this to control BottomNavigationBar colors
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF7C6FFF),
      unselectedItemColor: Colors.grey,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff1E1E1E),
    primaryColor: const Color(0xFF6C63FF),
    cardColor: const Color(0xFF2C2C2C),
    dividerColor: Colors.grey.shade700,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFF7C6FFF),
      surface: const Color(0xFF2C2C2C),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // ✅ BottomNavigationBar for dark theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      selectedItemColor: Color(0xFF7C6FFF),
      unselectedItemColor: Colors.grey,
    ),
  );
}
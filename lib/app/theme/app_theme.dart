import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  // Dark Mode - Android
  static const Color _scaffoldColorDark = Color.fromARGB(255, 26, 31, 37);
  static const Color _primaryColorDark = Color.fromARGB(255, 38, 45, 53);
  static const Color _secondaryColorDark = Color.fromARGB(255, 255, 210, 42);

  // static ThemeData platformIndiThemeData() {
  //   return platformThemeData(context, material: , cupertino: cupDark());
  // }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: GoogleFonts.manrope().fontFamily,
    ).copyWith(
      scaffoldBackgroundColor: _scaffoldColorDark,
      primaryColorDark: _primaryColorDark,
      primaryColor: _primaryColorDark,
      primaryColorLight: _primaryColorDark,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: _primaryColorDark,
        secondary: _secondaryColorDark,
      ),
      // Allow developers flexibility in text theme colors and font weights to suit specific UI details.
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: _secondaryColorDark,
        ),
        titleMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14),
        bodyMedium: TextStyle(fontSize: 12),
        bodySmall: TextStyle(fontSize: 10),
      ),
    );
  }

  // Dark Mode - IOS and MacOs
  static CupertinoThemeData cupDark() {
    return CupertinoThemeData(
      primaryColor: _primaryColorDark,
      applyThemeToAll: true,
      scaffoldBackgroundColor: _scaffoldColorDark,
      primaryContrastingColor: _secondaryColorDark,
      textTheme: CupertinoTextThemeData(textStyle: GoogleFonts.roboto()),
    );
  }
}
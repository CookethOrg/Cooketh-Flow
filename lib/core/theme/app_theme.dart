import "package:cookethflow/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

class AppTheme {
  static ThemeData light() {
    return ThemeData(useMaterial3: false, fontFamily: 'Frederik').copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      primaryColorDark: primaryColor,
      primaryColor: primaryColor,
      primaryColorLight: primaryColor,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryColor,
        secondary: secondaryColors[0], // Using green as secondary color
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 50.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        displayMedium: TextStyle(
          fontSize: 35.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        displaySmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(fontSize: 14, color: Colors.black),
        headlineSmall: TextStyle(fontSize: 12, color: Colors.black),
        titleLarge: TextStyle(fontSize: 10, color: Colors.black),
        bodyLarge: TextStyle(fontSize: 14, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 12, color: Colors.black),
        bodySmall: TextStyle(fontSize: 10, color: Colors.black),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: 'Frederik',
      brightness: Brightness.dark,
    ).copyWith(
      scaffoldBackgroundColor: scaffoldDarkColor,
      primaryColorDark: primaryColor,
      primaryColor: primaryColor,
      primaryColorLight: primaryColor,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryColor,
        secondary:
            secondaryColors[4], // Using cyan as secondary color for dark mode
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 50.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 35.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(fontSize: 14, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 12, color: Colors.white),
        titleLarge: TextStyle(fontSize: 10, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 12, color: Colors.white),
        bodySmall: TextStyle(fontSize: 10, color: Colors.white),
      ),

      // Custom dark theme components
      //cardTheme: CardTheme(color: scaffoldDarkColor, surfaceTintColor: scaffoldDarkColor),
      dividerTheme: DividerThemeData(color: tabBorderDarkColor),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldDarkColor,
        surfaceTintColor: scaffoldDarkColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffoldDarkColor,
      ),
    );
  }
}

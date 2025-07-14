import "package:cookethflow/core/theme/colors.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

class AppTheme {
  
  // Dark Mode - Android

  static ThemeData light() {
    return ThemeData(
      useMaterial3: false,
      // fontFamily: GoogleFonts.manrope().fontFamily,
    ).copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      primaryColorDark: primaryColor,
      primaryColor: primaryColor,
      primaryColorLight: primaryColor,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryColor,
        // secondary: _secondaryColorDark,
      ),
      
      // Allow developers flexibility in text theme colors and font weights to suit specific UI details.
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 50.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        titleMedium: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14),
        bodyMedium: TextStyle(fontSize: 12),
        bodySmall: TextStyle(fontSize: 10),
      ),
    );
  }

  // Dark Mode - IOS and MacOs
  // static CupertinoThemeData cupDark() {
  //   return CupertinoThemeData(
  //     primaryColor: _primaryColorDark,
  //     applyThemeToAll: true,
  //     scaffoldBackgroundColor: _scaffoldColorDark,
  //     primaryContrastingColor: _secondaryColorDark,
  //     // textTheme: CupertinoTextThemeData(textStyle: GoogleFonts.roboto()),
  //   );
  // }
}
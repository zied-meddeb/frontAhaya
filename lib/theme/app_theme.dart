import 'package:flutter/material.dart';
import 'package:shop/theme/button_theme.dart';
import 'package:shop/theme/input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';



class SupplierTheme {
  // Black and white theme colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);

  // Interface colors for black and white theme
  static const Color blackGradientStart = Color(0xFF000000);
  static const Color blackGradientEnd = Color(0xFF424242);
  static const Color whiteGradientStart = Color(0xFFFFFFFF);
  static const Color whiteGradientEnd = Color(0xFFF5F5F5);
  static const Color grayAccent = Color(0xFF757575);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlack,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryWhite,
      foregroundColor: primaryBlack,
      elevation: 0,
      centerTitle: false,
    ),
    //CardThemeData
    cardTheme: CardTheme(
      elevation: 4,
      color: primaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: mediumGray, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: primaryWhite,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: mediumGray, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlack, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryWhite,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      foregroundColor: primaryWhite,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      color: darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: mediumGray, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  // Black and white gradients
  static const LinearGradient blackGradient = LinearGradient(
    colors: [blackGradientStart, blackGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whiteGradient = LinearGradient(
    colors: [whiteGradientStart, whiteGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient grayGradient = LinearGradient(
    colors: [mediumGray, darkGray],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}



class AppTheme {
  static ThemeData lightTheme(BuildContext? context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: blackColor40),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
      // Add card theme for consistency
      cardTheme: CardTheme(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: blackColor20, width: 1),
        ),
      ),
    );
  }

  // Dark theme is inclided in the Full template
}

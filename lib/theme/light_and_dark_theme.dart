import 'package:flutter/material.dart';
import 'package:mogapabahi/theme/app_font_family.dart';
import 'package:mogapabahi/theme/colors_scheme.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: AppFontFamily.UberMoveMedium,
  primaryColor: AppColors.black,
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.grey80,
    background: AppColors.white,
    primary: AppColors.black,
    onBackground: AppColors.black,
    onSurface: AppColors.black,
  ),
  useMaterial3: true,
);

// final ThemeData darkTheme = ThemeData(
//   fontFamily: AppFontFamily.UberMoveMedium,
//   primaryColor: AppColors.white,
//   scaffoldBackgroundColor: AppColors.black,
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: AppColors.grey80,
//     background: AppColors.black,
//     primary: AppColors.white,
//     onBackground: AppColors.white,
//     onSurface: AppColors.white,
//   ),
//   useMaterial3: true,
// );

final ThemeData darkTheme = ThemeData(
  fontFamily: AppFontFamily.UberMoveMedium,
  primaryColor: AppColors.white,
  scaffoldBackgroundColor: AppColors.black,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.grey80,
    background: AppColors.black,
    primary: AppColors.white,
    onBackground: AppColors.white,
    onSurface: AppColors.white,
  ),
  useMaterial3: true,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.white,
    selectionColor: AppColors.grey80.withOpacity(0.5),
    selectionHandleColor: AppColors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.black,
    titleTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.black,
    textStyle: TextStyle(
      color: AppColors.white,
    ),
  ),
);

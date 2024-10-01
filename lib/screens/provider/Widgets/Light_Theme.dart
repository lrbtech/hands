import 'package:flutter/material.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
        background: AppColors.lightmode,
        primary: AppColors.purewhite,
        secondary: AppColors.purewhite,
        onSecondaryContainer: AppColors.darkstheme,
        surface: AppColors.darkstheme,
        onSurface: AppColors.unselectedcolor,
        onPrimary: AppColors.darkstheme,
        onBackground: AppColors.bgcolor,
        onSecondary: AppColors.darkstheme,
        onTertiary: AppColors.skyblue,
        onPrimaryContainer: AppColors.darkstheme,
        onError: AppColors.darkstheme));

import 'package:hands_user_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme { 
  //
  AppTheme._();

  static ThemeData lightTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(color ?? Color(0xFFFAF9F6)),
        primaryColor: color ?? Color(0xFFFAF9F6),
        colorScheme: ColorScheme.fromSeed(seedColor: color ?? Color(0xFFFAF9F6), outlineVariant: borderColor),
        scaffoldBackgroundColor: Color(0xFFFAF9F6),
        fontFamily: GoogleFonts.almarai().fontFamily,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Color(0xFFFAF9F6)),
        iconTheme: IconThemeData(color: appTextSecondaryColor),
        textTheme: GoogleFonts.almaraiTextTheme(),
        dialogBackgroundColor: Color(0xFFFAF9F6),
        unselectedWidgetColor: Color(0xFF000C2C) ,
        dividerColor: borderColor,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: Color(0xFFFAF9F6),
        ),
        cardColor: cardColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: color ?? Color(0xFFFAF9F6)),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
          ),
          scrolledUnderElevation: 0.0,
        ),
        dialogTheme: DialogTheme(shape: dialogShape()),
        navigationBarTheme: NavigationBarThemeData(labelTextStyle: MaterialStateProperty.all(primaryTextStyle(size: 10))),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData darkTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(color ?? Color(0xFF000C2C)),
        primaryColor: color ?? Color(0xFF000C2C),
        colorScheme: ColorScheme.fromSeed(seedColor: color ?? Color(0xFF000C2C), outlineVariant: borderColor),
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light), scrolledUnderElevation: 0.0),
        scaffoldBackgroundColor: Color(0xFF000C2C),
        fontFamily: GoogleFonts.almarai().fontFamily,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Color(0xFF000C2C)),
        iconTheme: IconThemeData(color: Color(0xFFFAF9F6)),
        textTheme: GoogleFonts.almaraiTextTheme(),
        dialogBackgroundColor: Color(0xFF000C2C),
        unselectedWidgetColor: Color(0xFFFAF9F6),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: Color(0xFF000C2C),
        ),
        dividerColor: dividerDarkColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: color ?? Color(0xFF000C2C)),
        cardColor: scaffoldSecondaryDark,
        dialogTheme: DialogTheme(shape: dialogShape()),
        navigationBarTheme: NavigationBarThemeData(labelTextStyle: MaterialStateProperty.all(primaryTextStyle(size: 10, color: Color(0xFF000C2C)))),
      ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}

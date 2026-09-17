import '../../../../../../utils/library.dart';
class AppTheme {
  //
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: GoogleFonts.beVietnamPro().fontFamily,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: const Color(0xFFF1F3F4),
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: scafoldColor,
      cardColor: cardColor,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white),
      iconTheme: IconThemeData(color: textPrimaryColorGlobal),
      textTheme: GoogleFonts.beVietnamProTextTheme(),
      unselectedWidgetColor: Colors.black,
      dividerColor: borderColor.withValues(alpha: 0.5),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(switchActiveTrackColor.withValues(alpha: 0.3)),
        thumbColor: WidgetStateProperty.all(switchActiveTrackColor),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        backgroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: scafoldColor,
          statusBarBrightness: Brightness.light,
          // statusBarColor: Color(0xFFF1F3F4),
        ),
      ),
      dialogTheme: DialogThemeData(shape: dialogShape(),backgroundColor: Colors.white,),
      pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: scaffoldDarkColor,
          statusBarBrightness: Brightness.light,
        ),
      ),
      scaffoldBackgroundColor: scaffoldDarkColor,
      fontFamily: GoogleFonts.beVietnamPro().fontFamily,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: GoogleFonts.beVietnamProTextTheme(),
      unselectedWidgetColor: Colors.white60,
      useMaterial3: true,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        backgroundColor: scaffoldDarkColor,
      ),
      dividerColor: dividerDarkColor.withValues(alpha: 0.2),
      cardColor: cardDarkColor,
      dialogTheme: DialogThemeData(shape: dialogShape(),backgroundColor: scaffoldSecondaryDark,),
      pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
      }),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();
  static final ThemeData defaultDarkTheme = _createDarkTheme();
  static final ThemeData defaultLightTheme = ThemeData.light();
}

@immutable
class AppColors {
  const AppColors();

  // Background Colors
  final Color darkBg = const Color(0xFF0A0A09);
  final Color darkBgLight = const Color(0xFF181816);
  final Color darkBgLightDropdown = const Color.fromARGB(255, 18, 18, 18);
  final Color lightBg = const Color(0xFFFFFFFF);

  // Primary and Accent Colors
  final Color primary = const Color(0xFFF8231C);
  final Color accent = const Color.fromARGB(255, 245, 75, 69);

  // Text Colors
  final Color foreground = const Color(
    0xFF181816,
  ); // Generally for text on light backgrounds
  final Color disabledText = const Color(0xFF696969);
  final Color enabledText = const Color(0xFFFFFFFF);
}

/// Internal helper to create the dark theme data.
ThemeData _createDarkTheme() {
  const AppColors colors = AppColors();

  return ThemeData(
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: colors.primary,
      onPrimary: colors.enabledText,
      secondary: colors.primary,
      onSecondary: colors.enabledText,
      error: colors.primary,
      onError: colors.enabledText,
      surface: colors.darkBg,
      onSurface: colors.enabledText,
    ),

    scaffoldBackgroundColor: colors.darkBg,

    appBarTheme: AppBarTheme(
      surfaceTintColor: colors.darkBg,
      backgroundColor: colors.darkBgLight,
      foregroundColor: colors.enabledText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.kumarOne(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colors.enabledText,
      ),
      toolbarTextStyle: GoogleFonts.kumarOne(
        fontSize: 16,
        color: colors.enabledText,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colors.enabledText,
        backgroundColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.kumarOne(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: GoogleFonts.kumarOne(fontSize: 16),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.kumarOne(fontSize: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.darkBg.withValues(
        alpha: 204,
      ), // Slightly transparent dark background (0.8 * 255 = 204)
      labelStyle: GoogleFonts.kumarOne(color: colors.disabledText),
      hintStyle: GoogleFonts.kumarOne(color: colors.disabledText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.disabledText, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ), // Using primary for error for consistency
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Added focused error border
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    cardTheme: CardThemeData(
      color: colors.darkBg,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.darkBg,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.disabledText,
      selectedIconTheme: IconThemeData(color: colors.primary, size: 24),
      unselectedIconTheme: IconThemeData(color: colors.disabledText, size: 24),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 10,
      ),
      type: BottomNavigationBarType.fixed,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.disabledText;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(
            alpha: 128,
          ); // 0.5 * 255 = 127.5, rounded to 128
        }
        return colors
            .darkBg; // Or a slightly different muted color for unselected track
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: colors.primary,
      inactiveTrackColor: colors.disabledText,
      thumbColor: colors.primary,
      overlayColor: colors.primary.withValues(
        alpha: 128,
      ), // 0.5 * 255 = 127.5, rounded to 128
      valueIndicatorColor: colors.primary,
      valueIndicatorTextStyle: GoogleFonts.kumarOne(color: colors.enabledText),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: colors.darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.kumarOne(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colors.enabledText,
      ),
      contentTextStyle: GoogleFonts.kumarOne(
        fontSize: 16,
        color: colors.disabledText,
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.darkBgLight;
      }),
      checkColor: WidgetStateProperty.all(colors.enabledText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.disabledText;
      }),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.darkBg.withValues(
          alpha: 230,
        ), // 0.9 * 255 = 229.5, rounded to 230
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.kumarOne(color: colors.enabledText, fontSize: 12),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.darkBg,
      contentTextStyle: GoogleFonts.kumarOne(color: colors.enabledText),
      actionTextColor: colors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: colors.primary,
      unselectedLabelColor: colors.disabledText,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colors.primary, width: 3.0),
      ),
      labelStyle: GoogleFonts.kumarOne(fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.kumarOne(),
    ),

    dividerTheme: DividerThemeData(
      color: colors.disabledText,
      thickness: 1,
      space: 16,
    ),

    iconTheme: IconThemeData(
      color: colors.enabledText,
      size: 24,
    ), // Default icon theme
    primaryIconTheme: IconThemeData(
      color: colors.enabledText,
      size: 24,
    ), // Icons in app bars etc.

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.enabledText,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}

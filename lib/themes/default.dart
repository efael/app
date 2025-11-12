import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:messenger/themes/application_theme.dart";

var lightApplicationTheme = ApplicationTheme(
  dominantBgHighContrast: Color.fromRGBO(210, 221, 235, 1),
  dominantBgMediumContrast: Color.fromRGBO(234, 239, 246, 1),
  dominantBgLowContrast: Colors.white,
  accentBluePrimary: Color.fromRGBO(54, 140, 204, 1),
  accentBlueSecondary: Color.fromRGBO(97, 170, 225, 1),
  accentGreen: Color.fromRGBO(42, 157, 99, 1),
  accentRed: Color.fromRGBO(252, 76, 83, 1),
  contentHighContrast: Color.fromRGBO(21, 29, 38, 1),
  contentLowContrast: Color.fromRGBO(77, 91, 106, 1),
);

var darkApplicationTheme = ApplicationTheme(
  dominantBgHighContrast: Color.fromRGBO(24, 35, 48, 1),
  dominantBgMediumContrast: Color.fromRGBO(33, 47, 63, 1),
  dominantBgLowContrast: Color.fromRGBO(49, 67, 86, 1),
  accentBluePrimary: lightApplicationTheme.accentBluePrimary,
  accentBlueSecondary: lightApplicationTheme.accentBlueSecondary,
  accentGreen: lightApplicationTheme.accentGreen,
  accentRed: lightApplicationTheme.accentRed,
  contentHighContrast: Color.fromRGBO(234, 244, 250, 1),
  contentLowContrast: Color.fromRGBO(108, 128, 140, 1),
);

var kDefaultTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.roboto().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: lightApplicationTheme.accentBluePrimary,
    brightness: Brightness.light,
    surface: lightApplicationTheme.dominantBgMediumContrast,
  ),
  scaffoldBackgroundColor: lightApplicationTheme.dominantBgMediumContrast,

  extensions: [lightApplicationTheme],
);

var kDarkDefaultTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.roboto().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: darkApplicationTheme.accentBluePrimary,
    brightness: Brightness.dark,
    surface: darkApplicationTheme.dominantBgMediumContrast,
  ),
  scaffoldBackgroundColor: darkApplicationTheme.dominantBgMediumContrast,
  extensions: [darkApplicationTheme],
);
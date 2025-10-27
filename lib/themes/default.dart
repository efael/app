import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger/constants.dart';

var kDefaultTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.roboto().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: consts.colors.accent.bluePrimary.light,
    brightness: Brightness.light,
    surface: consts.colors.dominant.bgMediumContrast.light,
  ),
  scaffoldBackgroundColor: consts.colors.dominant.bgMediumContrast.light,
);

var kDarkDefaultTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.roboto().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: consts.colors.accent.bluePrimary.dark,
    brightness: Brightness.dark,
    surface: consts.colors.dominant.bgMediumContrast.dark,
  ),
  scaffoldBackgroundColor: consts.colors.dominant.bgMediumContrast.dark,
);

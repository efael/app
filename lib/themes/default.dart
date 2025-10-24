import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var kDefaultTheme = ThemeData();

var kDarkDefaultTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.roboto().fontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
    surface: Color(0xFF212F3F),
  ),
  scaffoldBackgroundColor: Color(0xFF182330),
);

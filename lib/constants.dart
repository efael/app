import 'package:flutter/material.dart';

final _colors = (
  dominant: (
    bgHighContrast: (
      light: Color.fromRGBO(210, 221, 235, 1),
      dark: Color.fromRGBO(24, 35, 48, 1),
    ),
    bgMediumContrast: (
      light: Color.fromRGBO(234, 239, 246, 1),
      dark: Color.fromRGBO(33, 47, 63, 1),
    ),
    bgLowContrast: (light: Colors.white, dark: Color.fromRGBO(49, 67, 86, 1)),
  ),
  accent: (
    bluePrimary: (
      light: Color.fromRGBO(54, 140, 204, 1),
      dark: Color.fromRGBO(54, 140, 204, 1),
    ),
    blueSecondary: (
      light: Color.fromRGBO(97, 170, 225, 1),
      dark: Color.fromRGBO(97, 170, 225, 1),
    ),
    green: (
      light: Color.fromRGBO(42, 157, 99, 1),
      dark: Color.fromRGBO(42, 157, 99, 1),
    ),
    white: (light: Colors.white, dark: Colors.white),
    red: (
      light: Color.fromRGBO(252, 76, 83, 1),
      dark: Color.fromRGBO(252, 76, 83, 1),
    ),
  ),
  content: (
    highContrast: (
      light: Color.fromRGBO(21, 29, 38, 1),
      dark: Color.fromRGBO(234, 244, 250, 1),
    ),
    mediumContrast: (
      light: Color.fromRGBO(77, 91, 106, 1),
      dark: Color.fromRGBO(108, 128, 140, 1),
    ),
  ),
);

final consts = (
  colors: _colors,
  typography: (
    headline: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: _colors.content.highContrast.dark,
    ),
    text1: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: _colors.content.highContrast.dark,
    ),
    text2: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: _colors.content.mediumContrast.dark,
    ),
    text3: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: _colors.content.mediumContrast.dark.withValues(alpha: 0.9 * 255.0),
    ),
  ),
);

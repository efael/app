import 'package:flutter/material.dart';

final _colors = (
  dominant: (
    bgHighContrast: Color.fromRGBO(24, 35, 48, 1),
    bgMediumContrast: Color.fromRGBO(33, 47, 63, 1),
    bgLowContrast: Color.fromRGBO(49, 67, 86, 1),
  ),
  accent: (
    bluePrimary: Color.fromRGBO(54, 140, 204, 1),
    blueSecondary: Color.fromRGBO(97, 170, 225, 1),
    green: Color.fromRGBO(42, 157, 99, 1),
    white: Colors.white,
    red: Color.fromRGBO(252, 76, 83, 1),
  ),
  content: (
    highContrast: Color.fromRGBO(234, 244, 250, 1),
    mediumContrast: Color.fromRGBO(108, 128, 140, 1),
  ),
);

final consts = (
  colors: _colors,
  typography: (
    headline: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: _colors.content.highContrast,
    ),
    text1: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: _colors.content.highContrast,
    ),
    text2: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: _colors.content.mediumContrast,
    ),
    text3: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: _colors.content.mediumContrast.withValues(alpha: 0.9 * 255.0),
    ),
  ),
);

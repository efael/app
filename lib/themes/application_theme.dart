import "package:flutter/material.dart";

class ApplicationTheme extends ThemeExtension<ApplicationTheme> {
  ApplicationTheme({
    required this.dominantBgHighContrast,
    required this.dominantBgMediumContrast,
    required this.dominantBgLowContrast,

    required this.accentBluePrimary,
    required this.accentBlueSecondary,
    required this.accentGreen,
    this.accentWhite = Colors.white,
    required this.accentRed,

    required this.contentHighContrast,
    required this.contentLowContrast,
  });

  Color dominantBgHighContrast;
  Color dominantBgMediumContrast;
  Color dominantBgLowContrast;

  Color accentBluePrimary;
  Color accentBlueSecondary;
  Color accentGreen;
  Color accentWhite;
  Color accentRed;

  Color contentHighContrast;
  Color contentLowContrast;

  @override
  ThemeExtension<ApplicationTheme> copyWith({
    Color? dominantBgHighContrast,
    Color? dominantBgMediumContrast,
    Color? dominantBgLowContrast,

    Color? accentBluePrimary,
    Color? accentBlueSecondary,
    Color? accentGreen,
    Color? accentWhite,
    Color? accentRed,

    Color? contentHighContrast,
    Color? contentLowContrast,
  }) => ApplicationTheme(
    dominantBgHighContrast:
        dominantBgHighContrast ?? this.dominantBgHighContrast,
    dominantBgMediumContrast:
        dominantBgMediumContrast ?? this.dominantBgMediumContrast,
    dominantBgLowContrast: dominantBgLowContrast ?? this.dominantBgLowContrast,

    accentBluePrimary: accentBluePrimary ?? this.accentBluePrimary,
    accentBlueSecondary: accentBlueSecondary ?? this.accentBlueSecondary,
    accentGreen: accentGreen ?? this.accentGreen,
    accentWhite: accentWhite ?? this.accentWhite,
    accentRed: accentRed ?? this.accentRed,

    contentHighContrast: contentHighContrast ?? this.contentHighContrast,
    contentLowContrast: contentLowContrast ?? this.contentLowContrast,
  );

  @override
  ThemeExtension<ApplicationTheme> lerp(
    covariant ThemeExtension<ApplicationTheme>? other,
    double t,
  ) {
    if (other is! ApplicationTheme) {
      return this;
    }

    return ApplicationTheme(
      dominantBgHighContrast: Color.lerp(
        dominantBgHighContrast,
        other.dominantBgHighContrast,
        t,
      )!,
      dominantBgMediumContrast: Color.lerp(
        dominantBgMediumContrast,
        other.dominantBgMediumContrast,
        t,
      )!,
      dominantBgLowContrast: Color.lerp(
        dominantBgLowContrast,
        other.dominantBgLowContrast,
        t,
      )!,
      accentBluePrimary: Color.lerp(
        accentBluePrimary,
        other.accentBluePrimary,
        t,
      )!,
      accentBlueSecondary: Color.lerp(
        accentBlueSecondary,
        other.accentBlueSecondary,
        t,
      )!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentWhite: Color.lerp(accentWhite, other.accentWhite, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      contentHighContrast: Color.lerp(
        contentHighContrast,
        other.contentHighContrast,
        t,
      )!,
      contentLowContrast: Color.lerp(
        contentLowContrast,
        other.contentLowContrast,
        t,
      )!,
    );
  }
}

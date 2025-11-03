import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:widgetbook/widgetbook.dart';

/// A [WidgetbookAddon] for switching between different locales.
///
/// [LocalizationGetxAddon] enables users to test their widgets with different locales
/// and localizations. This is essential for apps that support multiple languages
/// or regions, allowing developers to verify that text, formatting, and layout
/// work correctly across different locales.
///
/// Learn more: https://docs.widgetbook.io/addons/localization-addon
class LocalizationGetxAddon extends WidgetbookAddon<Locale> {
  /// Creates a new instance of [LocalizationGetxAddon].
  LocalizationGetxAddon({
    required this.supportedLocales,
    required this.localizationsDelegates,
    this.locale,
    this.translations,
  }) : assert(supportedLocales.isNotEmpty, 'locales cannot be empty'),
       assert(
         locale == null || supportedLocales.contains(locale),
         'initialLocale must be in locales',
       ),
       super(name: 'Locale');

  /// The default locale selection when the addon is first loaded.
  ///
  /// If null, the first locale in [supportedLocales] will be used as the default.
  final Locale? locale;

  /// The list of supported locales available for selection.
  ///
  /// These locales will appear in the dropdown menu in the settings panel.
  /// The list cannot be empty.
  final List<Locale> supportedLocales;

  /// The localization delegates that provide localized content.
  ///
  /// These delegates are responsible for loading and providing localized
  /// strings, date/number formatting, and other locale-specific content.
  /// Typically includes Material, Widgets, and Cupertino delegates.
  final List<LocalizationsDelegate<dynamic>> localizationsDelegates;

  final Translations? translations;

  @override
  List<Field> get fields {
    return [
      ObjectDropdownField<Locale>(
        name: 'name',
        values: supportedLocales,
        initialValue: locale ?? supportedLocales.first,
        labelBuilder: (locale) => locale.toLanguageTag(),
      ),
    ];
  }

  @override
  Locale valueFromQueryGroup(Map<String, String> group) {
    return valueOf('name', group)!;
  }

  @override
  Widget buildUseCase(BuildContext context, Widget child, Locale setting) {
    if (translations != null) {
      Get.addTranslations(translations!.keys);
    }

    Get.locale = setting;

    return Localizations(
      locale: setting,
      delegates: localizationsDelegates,
      child: child,
    );
  }
}

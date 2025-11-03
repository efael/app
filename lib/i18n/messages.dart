import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/i18n/en.dart';
import 'package:messenger/i18n/ru.dart';
import 'package:messenger/i18n/uz.dart';

class Messages extends Translations {
  static get defaultLang => const Locale('ru', 'RU');

  @override
  Map<String, Map<String, String>> get keys => {
    "uz": AppLocalizationsUz.translations,
    "ru": AppLocalizationsRu.translations,
    "en": AppLocalizationsEn().finalTranslations,
  };

  static List<Language> languages = [
    Language(key: "uz", label: "O'zbekcha"),
    Language(key: "ru", label: "Русский"),
    Language(key: "en", label: "English"),
  ];

  static String get activeLangLabel {
    var key = Get.locale?.languageCode;
    if (key == null) {
      return "";
    }

    return languages.firstWhere((it) => it.key == key).label;
  }
}

class Language {
  String key;
  String label;

  Language({required this.key, required this.label});
}

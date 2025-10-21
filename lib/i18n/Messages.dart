import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/i18n/en.dart';
import 'package:messenger/i18n/uz.dart';
import 'package:messenger/i18n/ru.dart';

class Messages extends Translations {
  static get defaultLang => const Locale('ru');

  @override
  Map<String, Map<String, String>> get keys => {
    "uz": AppLocalizationsUz.translations,
    "ru": AppLocalizationsRu.translations,
    "en": AppLocalizationsEn.translations,
  };

  static List<Language> languages = [
    Language(key: "uz", label: "O'zbekcha"),
    Language(key: "ru", label: "Русский"),
    Language(key: "en", label: "English"),
  ];
}

class Language {
  String key;
  String label;

  Language({required this.key, required this.label});
}

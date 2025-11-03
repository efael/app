abstract class LocaleExtension {
  String get prefix => "";

  Map<String, String> get translations;

  List<LocaleExtension> get extensions => [];

  Map<String, String> get finalTranslations {
    var pref = prefix;
    if (pref != "" && !pref.endsWith(".")) {
      pref = "$pref.";
    }

    var base = Map.fromEntries(
      translations.entries.map(
        (entry) => MapEntry("$pref${entry.key}", entry.value),
      ),
    );

    for (final ext in extensions) {
      var child = ext.finalTranslations;
      base.addAll(child);
    }

    return base;
  }
}

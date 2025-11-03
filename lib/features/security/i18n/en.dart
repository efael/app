import "package:messenger/i18n/extension.dart";

import "common.dart";

class SecurityLocalizationsEn extends LocaleExtension {
  @override
  String get prefix => localePrefix;

  @override
  Map<String, String> get translations => {
    // setup ui
    "setupRecovery": "Set up recovery",
    "recoveryKey": "Recovery key",
    "generateRecoveryKey": "Generate recovery key",
    "generating": "Generating...",
    "dontShare": "Don't share this information with anyone!",
    "tapToCopy": "Tap to copy recovery key",
    "saveRecoveryKey": "Save recovery key",
    "done": "Done",
  };
}

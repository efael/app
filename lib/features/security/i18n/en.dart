import "package:messenger/i18n/extension.dart";

import "common.dart";

class SecurityLocalizationsEn extends LocaleExtension {
  @override
  String get prefix => localePrefix;

  @override
  Map<String, String> get translations => {
    "done": "Done",
    "cancel": "Cancel",

    // setup ui
    "setupRecovery": "Set up recovery",
    "recoveryKey": "Recovery key",
    "generateRecoveryKey": "Generate recovery key",
    "generating": "Generating...",
    "dontShare": "Don't share this information with anyone!",
    "tapToCopy": "Tap to copy recovery key",
    "saveRecoveryKey": "Save recovery key",

    // reset ui
    "cantConfirmReset": "Can't confirm? Reset your identity.",
    "continueReset": "Continue reset",
    "areYouSureToReset": "Are you sure?",
    "areYouSureToResetContent": "This process is irreversible!",
    "areYouSureToResetButton": "Yes, reset now",
  };
}

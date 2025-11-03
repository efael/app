import 'package:messenger/features/onboarding/i18n/common.dart';
import 'package:messenger/i18n/extension.dart';

class OnboardingLocalizationsEn extends LocaleExtension {
  @override
  String get prefix => localePrefix;

  @override
  Map<String, String> get translations => {
    "signOut": "Sign out",
    "confirmIdentity": "Confirm your identity",
    "useAnotherDevice": "Use another device",
    "enterRecoveryKey": "Enter recovery key",
    "cantConfirm": "Can't confirm?",
  };
}

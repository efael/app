import 'package:messenger/features/onboarding/i18n/en.dart';
import 'package:messenger/i18n/extension.dart';

class AppLocalizationsEn extends LocaleExtension {
  @override
  Map<String, String> get translations => {
    "contacts": "Contacts",
    "calls": "Calls",
    "chats": "Chats",
    "settings": "Settings",
    "now": "Now",
    "min": "min",
    "yesterday": "Yesterday",
    "all": "All",
    "empty": "Empty",
    "incoming": "Incoming",
    "outgoing": "Outgoing",
    "missed": "Missed",
    "warning": "Warning",
    "logoutText": "Do you really want to log out of the application",
    "yes": "Yes",
    "no": "No",
    "language": "Language",
    "select_lang": "Select language",
    "cancel": "Cancel",
    "message": "Messages",
  };

  @override
  List<LocaleExtension> get extensions => [OnboardingLocalizationsEn()];
}

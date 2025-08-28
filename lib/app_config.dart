import 'package:messenger/src/bindings/bindings.dart';

class AppConfig {
  static const appName = "Efael";
  static const homeserver = "efael.uz";
  static const appOpenUrlScheme = "uz.efael.messenger";
  static const oidcConfiguration = OidcConfiguration(
    redirectUri: "$appOpenUrlScheme:/",
    clientName: "Efael",
    clientUri: "https://efael.uz",
    staticRegistrations: {},
  );
}

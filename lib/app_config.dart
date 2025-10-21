import 'dart:io';

import 'package:messenger/src/bindings/bindings.dart';

class AppConfig {
  static const appName = "Efael";
  static const homeserver = "efael.uz";
  static final useWebview = Platform.isAndroid || Platform.isIOS;
  static final appOpenUrlScheme = useWebview
      ? "uz.efael.messenger"
      : Platform.isLinux || Platform.isWindows
      ? "http://localhost:41337"
      : "";
  static final oidcConfiguration = OidcConfiguration(
    redirectUri: useWebview ? "$appOpenUrlScheme:/" : appOpenUrlScheme,
    clientName: "Efael",
    clientUri: "https://efael.uz",
    staticRegistrations: {},
  );
}

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:messenger/AppConfig.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:rinf/rinf.dart';

import 'AppBinding.dart';
import 'AppPages.dart';
import 'AppRoutes.dart';
import 'i18n/Messages.dart';
import 'themes/default.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeRust(assignRustSignal);
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppLifecycleListener _listener;
  late final StreamSubscription<RustSignalPack<MatrixLogoutResponse>>
  _logoutListener;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onExitRequested: () async {
        finalizeRust(); // Shut down the async Rust runtime.
        return AppExitResponse.exit;
      },
    );

    _logoutListener = MatrixLogoutResponse.rustSignalStream.listen((signal) {
      Get.offAndToNamed(AppRoutes.auth);
    });
  }

  @override
  void dispose() {
    _logoutListener.cancel();
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      translations: Messages(),
      locale: Messages.defaultLang,
      debugShowCheckedModeBanner: false,
      theme: kDefaultTheme,
      darkTheme: kDarkDefaultTheme,
      themeMode: ThemeMode.dark,
      getPages: AppPages.routes,
      initialRoute: AppRoutes.base,
      initialBinding: AppBinding(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uz', 'UZ'),
        Locale('ru', 'RU'),
        Locale('en', 'EN'),
      ],
    );
  }
}

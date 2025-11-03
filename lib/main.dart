import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:messenger/binding.dart';
import 'package:messenger/config.dart';
import 'package:messenger/i18n/messages.dart';
import 'package:messenger/pages.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/themes/default.dart';
import 'package:messenger/widgetbook/localization_getx_addon.dart';
import 'package:rinf/rinf.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'main.directories.g.dart';

const widgetbookEnabled =
    String.fromEnvironment('WIDGETBOOK', defaultValue: 'disable') == 'enable';

void main() async {
  if (widgetbookEnabled) {
    runApp(WidgetbookApp());
    return;
  }

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

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      lightTheme: kDefaultTheme,
      darkTheme: kDarkDefaultTheme,
      themeMode: ThemeMode.dark,
      directories: directories,
      addons: [
        LocalizationGetxAddon(
          translations: Messages(),
          locale: Messages.defaultLang,
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
        ),
        ThemeAddon(
          initialTheme: WidgetbookTheme(name: 'Dark', data: kDarkDefaultTheme),
          themes: [
            WidgetbookTheme(name: 'Light', data: kDefaultTheme),
            WidgetbookTheme(name: 'Dark', data: kDarkDefaultTheme),
          ],
          themeBuilder: (context, theme, child) =>
              Theme(data: theme, child: child),
        ),
      ],
    );
  }
}

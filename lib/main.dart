import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AppBinding.dart';
import 'AppPages.dart';
import 'AppRoutes.dart';
import 'i18n/Messages.dart';
import 'themes/default.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetSecureStorage.init(password: 'strongpassword');

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Efael',
      translations: Messages(),
      locale: Messages.defaultLang,
      debugShowCheckedModeBanner: false,
      theme: kDefaultTheme,
      darkTheme: kDarkDefaultTheme,
      themeMode: ThemeMode.dark,
      getPages: AppPages.routes,
      initialRoute: AppRoutes.BASE,
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

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/app_config.dart';
import 'package:messenger/router.dart';
import 'package:messenger/src/bindings/bindings.dart';
import 'package:messenger/theme.dart';
import 'package:rinf/rinf.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
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
      navigatorKey.currentContext?.go("/authorize");
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
    return MaterialApp.router(
      title: AppConfig.appName,
      themeMode: ThemeMode.dark,
      darkTheme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

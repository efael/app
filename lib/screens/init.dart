import 'package:flutter/material.dart';
import 'package:messenger/app_config.dart';
import 'package:messenger/screens/splash.dart';
import 'package:messenger/src/bindings/signals/signals.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  void initRust() async {
    final applicationSupportDirectory = await getApplicationSupportDirectory();

    MatrixInitRequest(
      homeserverUrl: AppConfig.homeserver,
      applicationSupportDirectory: applicationSupportDirectory.path,
    ).sendSignalToRust();
  }

  @override
  void initState() {
    super.initState();

    initRust();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MatrixInitResponse.rustSignalStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SplashScreen();
        }

        switch (snapshot.data!.message) {
          case MatrixInitResponseOk(isLoggedIn: final isLoggedIn):
            if (isLoggedIn) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go('/chats'),
              );
            } else {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go('/authorize'),
              );
            }
            return const SplashScreen();
          case MatrixInitResponseErr(message: final message):
            print(message);
            return const SplashScreen();
        }

        return const SplashScreen();
      },
    );
  }
}

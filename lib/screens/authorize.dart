import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/app_config.dart';
import 'package:messenger/src/bindings/bindings.dart';

class AuthorizeScreen extends StatefulWidget {
  const AuthorizeScreen({super.key});

  @override
  State<AuthorizeScreen> createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends State<AuthorizeScreen> {
  final statesController = WidgetStatesController();

  void authorize() async {
    setState(() {
      statesController.update(WidgetState.disabled, true);
    });

    MatrixOidcAuthRequest(
      oidcConfiguration: AppConfig.oidcConfiguration,
    ).sendSignalToRust();

    try {
      final authUrl = await MatrixOidcAuthResponse.rustSignalStream.first;

      /*
      TODO:
      Error handling, retry, connection issues, cross platform check
    */

      switch (authUrl.message) {
        case MatrixOidcAuthResponseOk(url: final url):
          final callbackUrl = await FlutterWebAuth2.authenticate(
            url: url,
            // https://pub.dev/packages/flutter_web_auth_2#ios
            // callbackUrlScheme: Platform.isIOS
            //     ? "https"
            //     : AppConfig.appOpenUrlScheme,
            callbackUrlScheme: AppConfig.appOpenUrlScheme,
            options: const FlutterWebAuth2Options(
              intentFlags: ephemeralIntentFlags,
            ),
          );

          // print(callbackUrl);
          MatrixOidcAuthFinishRequest(url: callbackUrl).sendSignalToRust();

          final response =
              await MatrixOidcAuthFinishResponse.rustSignalStream.first;

          switch (response.message) {
            case MatrixOidcAuthFinishResponseOk():
              // print("finished");
              if (mounted) context.go("/chat-list");
            case MatrixOidcAuthFinishResponseErr():
            // print(message);
          }

        case MatrixOidcAuthResponseErr():
        // print(message);
      }
    } catch (err) {
      print(err);
    } finally {
      setState(() {
        statesController.update(WidgetState.disabled, false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Authorize",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        authorize();
                      },
                      child: const Text("Authorize"),
                      statesController: statesController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

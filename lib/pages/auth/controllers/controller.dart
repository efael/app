import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:messenger/AppConfig.dart';
import 'package:messenger/AppRoutes.dart';
import 'package:messenger/rinf/bindings/bindings.dart';

import '../../BaseController.dart';
import 'package:get/get.dart';

class AuthController extends BaseController {
  var loading = false.obs;

  void authorize() async {
    loading.value = true;

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
            options: FlutterWebAuth2Options(
              intentFlags: defaultIntentFlags,
              useWebview: AppConfig.useWebview,
            ),
          );

          // print(callbackUrl);
          MatrixOidcAuthFinishRequest(url: callbackUrl).sendSignalToRust();

          final response =
              await MatrixOidcAuthFinishResponse.rustSignalStream.first;

          switch (response.message) {
            case MatrixOidcAuthFinishResponseOk():
              Get.offAndToNamed(AppRoutes.home);
              return;
            case MatrixOidcAuthFinishResponseErr():
            // print(message);
          }

        case MatrixOidcAuthResponseErr():
        // print(message);
      }
    } catch (err) {
      print(err);
    } finally {
      loading.value = false;
    }
  }
}

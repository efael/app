import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:messenger/themes/application_theme.dart";

import "../i18n/common.dart";

class OnboardingVerifyUI extends StatelessWidget {
  const OnboardingVerifyUI({
    super.key,
    this.signOutCallback,

    this.useAnotherDeviceEnabled = false,
    this.useAnotherDeviceCallback,

    this.enterRecoveryKeyEnabled = false,
    this.enterRecoveryKeyCallback,

    this.cantConfirmEnabled = false,
    this.cantConfirmCallback,
  });

  final VoidCallback? signOutCallback;

  final bool useAnotherDeviceEnabled;
  final VoidCallback? useAnotherDeviceCallback;

  final bool enterRecoveryKeyEnabled;
  final VoidCallback? enterRecoveryKeyCallback;

  final bool cantConfirmEnabled;
  final VoidCallback? cantConfirmCallback;

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<ApplicationTheme>()!;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: signOutCallback,
                  child: Text("$localePrefix.signOut".tr),
                ),
              ],
            ),

            SizedBox(height: 32),

            Column(
              spacing: 6,
              children: [
                Icon(Icons.lock),
                Text(
                  "$localePrefix.confirmIdentity".tr,
                  style: TextStyle(color: appTheme.contentHighContrast),
                ),
              ],
            ),

            Expanded(child: SizedBox.shrink()),

            Column(
              spacing: 12,
              children: [
                if (useAnotherDeviceEnabled)
                  FilledButton(
                    onPressed: useAnotherDeviceCallback,
                    child: Text("$localePrefix.useAnotherDevice".tr),
                  ),
                if (enterRecoveryKeyEnabled)
                  FilledButton(
                    onPressed: enterRecoveryKeyCallback,
                    child: Text("$localePrefix.enterRecoveryKey".tr),
                  ),
                if (cantConfirmEnabled)
                  OutlinedButton(
                    onPressed: cantConfirmCallback,
                    child: Text("$localePrefix.cantConfirm".tr),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

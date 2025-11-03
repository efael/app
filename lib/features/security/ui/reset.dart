import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:messenger/themes/application_theme.dart";

import "../i18n/common.dart";

class SecurityResetUI extends StatelessWidget {
  const SecurityResetUI({super.key, this.backCallback, this.resetCallback});

  final VoidCallback? backCallback;
  final VoidCallback? resetCallback;

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<ApplicationTheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: IconButton(
          onPressed: backCallback,
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(Icons.warning),
            Text("$localePrefix.cantConfirmReset".tr),
            Expanded(child: SizedBox()),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: appTheme.accentRed,
                foregroundColor: appTheme.accentWhite,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("$localePrefix.areYouSureToReset".tr),
                  content: Text("$localePrefix.areYouSureToResetContent".tr),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("$localePrefix.cancel".tr),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: appTheme.accentRed,
                        foregroundColor: appTheme.accentWhite,
                      ),
                      onPressed: resetCallback,
                      child: Text("$localePrefix.areYouSureToResetButton".tr),
                    ),
                  ],
                ),
              ),
              child: Text("$localePrefix.continueReset".tr),
            ),
          ],
        ),
      ),
    );
  }
}

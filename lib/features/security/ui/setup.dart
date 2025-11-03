import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:messenger/themes/application_theme.dart";

import "../i18n/common.dart";

class SecuritySetupUI extends StatelessWidget {
  const SecuritySetupUI({
    super.key,
    this.backCallback,
    this.generateRecoveryKeyCallback,
    this.copyKeysCallback,
    this.saveRecoveryKeyCallback,
    this.doneCallback,
    this.generating = false,
    this.keys,
  });

  final VoidCallback? backCallback;
  final VoidCallback? generateRecoveryKeyCallback;
  final VoidCallback? copyKeysCallback;
  final VoidCallback? saveRecoveryKeyCallback;
  final VoidCallback? doneCallback;
  final bool generating;
  final String? keys;

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
          spacing: 32,
          children: [
            Column(
              spacing: 8,
              children: [
                Icon(Icons.key),
                Text("$localePrefix.setupRecovery".tr),
              ],
            ),
            Column(
              spacing: 8,
              children: [
                Text("$localePrefix.recoveryKey".tr),

                if (keys != null)
                  GestureDetector(
                    onTap: copyKeysCallback,
                    child: Container(
                      decoration: BoxDecoration(
                        color: appTheme.dominantBgHighContrast,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(32),
                      child: Text(
                        keys!,
                        style: TextStyle(
                          fontFamily: GoogleFonts.robotoMono().fontFamily,
                        ),
                      ),
                    ),
                  )
                else if (!generating)
                  FilledButton(
                    onPressed: generateRecoveryKeyCallback,
                    child: Text("$localePrefix.generateRecoveryKey".tr),
                  )
                else
                  FilledButton.icon(
                    onPressed: null,
                    icon: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        // color: appTheme.accentBluePrimary,
                        strokeWidth: 2,
                      ),
                    ),
                    label: Text("$localePrefix.generating".tr),
                  ),

                Text(
                  keys == null
                      ? "$localePrefix.dontShare".tr
                      : "$localePrefix.tapToCopy".tr,
                ),
              ],
            ),

            Expanded(child: SizedBox.shrink()),

            Column(
              spacing: 8,
              children: [
                if (keys != null)
                  OutlinedButton.icon(
                    onPressed: saveRecoveryKeyCallback,
                    icon: Icon(Icons.save_alt),
                    label: Text("$localePrefix.saveRecoveryKey".tr),
                  ),
                FilledButton(
                  onPressed: doneCallback,
                  child: Text("$localePrefix.done".tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

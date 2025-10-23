{
  pkgs,
  commonInputs,
  xcodeenv,
  androidCustomPackage,
  pinnedJDK,
  localToolchainPath,
  localFlutter,
  localFlutterPath,
  ...
}:
pkgs.mkShellNoCC {
  nativeBuildInputs =
    commonInputs
    ++ [
      (xcodeenv.composeXcodeWrapper {versions = ["16.2"];})
      pkgs.cocoapods
    ];
  ANDROID_SDK_ROOT = "${androidCustomPackage}/share/android-sdk";
  JAVA_HOME = pinnedJDK;

  shellHook = ''
    unset DEVELOPER_DIR
    unset SDKROOT

    mkdir -p ${localToolchainPath}

    # installs flutter locally, if not there already
    ${localFlutter.unpack_flutter}/bin/unpack_flutter
    export PATH="${localFlutterPath}/flutter/bin:$PATH"
  '';
}

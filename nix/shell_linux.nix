{
  pkgs,
  commonInputs,
  androidCustomPackage,
  pinnedJDK,
  pinnedFlutter,
  androidEmulator,
  ...
}:
pkgs.mkShellNoCC {
  nativeBuildInputs =
    commonInputs
    ++ (with pkgs; [
      pkg-config
      gcc
      openssl
      pinnedFlutter
      virtualgl
      google-chrome
      webkitgtk_4_1
    ]);
  ANDROID_SDK_ROOT = "${androidCustomPackage}/share/android-sdk";
  JAVA_HOME = pinnedJDK;
  FLUTTER_ROOT = "${pinnedFlutter}";
  CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidCustomPackage}/share/android-sdk/build-tools/35.0.0/aapt2";

  # thanks to https://github.com/google/note-maps/blob/main/nix/default.nix
  # ${pinnedFlutter}/bin/flutter config --android-studio-dir=${pkgs.android-studio}

  # CARGO_ENCODED_RUSTFLAGS = "-L ${androidOpenssl}/ssl_3/x86_64 -L ${androidOpenssl}/ssl_3/x86";
  shellHook = ''
    echo ""
    echo ===================================================
    echo ===================================================
    echo ""

    echo "to run android emulator, execute: ${androidEmulator}/bin/run-test-emulator"

    echo ""
    echo ===================================================
    echo ===================================================
    echo ""
  '';
}

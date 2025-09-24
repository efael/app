{
  # this flake file mainly inspired from https://github.com/patmuk/flutter-UI_rust-BE-example

  description = "Efael messenger based on Matrix protocol";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    fenix,
    android-nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
      rinf = pkgs.callPackage ./nix/rinf.nix {};
      localToolchainPath = "$PWD/.toolchain";
      localFlutterPath = "${localToolchainPath}/flutter-local";
      localFlutter = pkgs.callPackage ./nix/flutter.nix {inherit localFlutterPath;};
      # https://github.com/NixOS/nixpkgs/issues/355486
      # mkShellNoCC = pkgs.mkShellNoCC.override {
      #   stdenv = pkgs.stdenvNoCC.override {extraBuildInputs = [];};
      # };
      targetPlatforms =
        (
          if pkgs.stdenv.isDarwin
          then [
            "aarch64-apple-darwin"
            "aarch64-apple-ios"
            "aarch64-apple-ios-sim"
          ]
          else if pkgs.stdenv.isLinux
          then []
          else []
        )
        ++ [
          "aarch64-linux-android"
          "wasm32-unknown-unknown"
          # emulators
          "x86_64-apple-ios"
          "i686-linux-android"
          "x86_64-linux-android"
          "x86_64-unknown-linux-gnu"
        ];
      rustToolchain = with fenix.packages.${system};
        combine ((with stable; [
            cargo
            rustc
            rust-analyzer
            clippy
            rustfmt
          ])
          ++ builtins.map (x: targets.${x}.stable.rust-std) targetPlatforms);

      xcodeenv = import (nixpkgs + "/pkgs/development/mobile/xcodeenv") {inherit (pkgs) callPackage;};
      androidCustomPackage = android-nixpkgs.sdk.${system} (
        # show all potential values with
        # nix flake show github:tadfisher/android-nixpkgs
        sdkPkgs:
          with sdkPkgs; [
            cmdline-tools-latest
            # cmdline-tools-17-0
            # build-tools-33-0-1
            # build-tools-34-0-0
            cmake-3-22-1
            build-tools-35-0-0
            # ndk-23-1-7779620
            # ndk-26-1-10909125
            ndk-27-0-12077973
            # ndk-28-0-13004108
            platform-tools
            emulator
            # platforms-android-33
            platforms-android-34
            # platforms-android-35
            platforms-android-36
            system-images-android-34-aosp-atd-arm64-v8a #basic image, 40% faster
            system-images-android-34-google-apis-arm64-v8a #google branded
            system-images-android-34-google-apis-playstore-arm64-v8a #google branded with playstore installed
            # system-images-android-35-aosp-atd-arm64-v8a #basic image, 40% faster
            # system-images-android-35-google-apis-arm64-v8a #google branded
            # system-images-android-35-google-apis-playstore-arm64-v8a #google branded with playstore installed
            system-images-android-36-aosp-atd-arm64-v8a #basic image, 40% faster
            system-images-android-36-google-apis-arm64-v8a #google branded
            system-images-android-36-google-apis-playstore-arm64-v8a #google branded with playstore installed
          ]
      );
      pinnedJDK = pkgs.jdk17_headless;
      pinnedFlutter = pkgs.flutter;
      commonInputs = [
        rinf
        rustToolchain
        androidCustomPackage
        pinnedJDK
      ];
    in {
      devShells.default =
        if pkgs.stdenv.isLinux
        then
          pkgs.mkShell {
            nativeBuildInputs =
              commonInputs
              ++ (with pkgs; [
                pkg-config
                openssl
                pinnedFlutter
                virtualgl
                google-chrome
              ]);
            ANDROID_SDK_ROOT = "${androidCustomPackage}/share/android-sdk";
            # Use this to create an android emulator
            # however, this is not needed, as VSCode's Flutter Plugin can create emulators as well
            # to anable the hardware keyboad and the android buttons, go to
            # ~/.android/avd/<emu-name>/config.ini
            # and set `hw.keyboard = yes` and `hw.mainKeys = yes`
            # AVD_package = "system-images;android-34;aosp_atd;arm64-v8a";
            # local_SDK_path = "${local_toolchain_path}/android";
            # local_AVD_path = "${local_SDK_path}/AVD";
            # avdmanager create avd --name android-34-pixel_8 --package '${AVD_package}' --device "pixel_8"
            JAVA_HOME = pinnedJDK;
            FLUTTER_ROOT = "${pinnedFlutter}";
            CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidCustomPackage}/share/android-sdk/build-tools/35.0.0/aapt2";

            NIX_LDFLAGS = pkgs.lib.concatLines (builtins.map (x: "-L${x}/lib") [
              pkgs.openssl
              # pkgs.pkgsCross.x86_64-embedded.openssl
            ]);

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.openssl
            ];

            # thanks to https://github.com/google/note-maps/blob/main/nix/default.nix
            shellHook = ''
              # ${pinnedFlutter}/bin/flutter config --android-studio-dir=${pkgs.android-studio}
            '';
          }
        else if pkgs.stdenv.isDarwin
        then
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
        else pkgs.mkShell {};
    });
}

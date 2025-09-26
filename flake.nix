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
            "x86_64-apple-ios"
          ]
          else if pkgs.stdenv.isLinux
          then [
            "x86_64-unknown-linux-gnu"
          ]
          else []
        )
        ++ [
          "aarch64-linux-android"
          "wasm32-unknown-unknown"
          # emulators
          "i686-linux-android"
          "x86_64-linux-android"
        ];
      rustToolchain = with fenix.packages.${system};
        combine ((with stable; [
            cargo
            rustc
            rust-src
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
            cmake-3-22-1
            build-tools-35-0-0
            ndk-27-0-12077973
            platform-tools
            platforms-android-34
            emulator
            platforms-android-36
            system-images-android-36-google-apis-playstore-x86-64
          ]
      );
      androidEmulator = pkgs.androidenv.emulateApp {
        name = "emulator";
        platformVersion = "36";
        abiVersion = "x86_64";
        systemImageType = "google_apis_playstore";
        configOptions = {
          "hw.gpu.enabled" = "yes";
          "hw.gpu.mode" = "swiftshader_indirect";
          "hw.keyboard" = "yes";
          "hw.kainKeys" = "yes";
        };
      };
      # androidOpenssl = pkgs.fetchFromGitHub {
      #   owner = "KDAB";
      #   repo = "android_openssl";
      #   rev = "0025bbe48f69792f95e02c9289df0fae68c954d6";
      #   sha256 = "sha256-+RCaW8qvSJ3/pgJl5abjao9EtvTE+l53r4XeSoCxmLM=";
      # };
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

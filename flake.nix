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
      mkShellNoCC = pkgs.mkShellNoCC;
      rustToolchain = fenix.packages.${system}.fromToolchainFile {
        file = ./rust-toolchain.toml;
        sha256 = "sha256-+9FmLhAOezBZCOziO0Qct1NOrfpjNsXxc/8I0c7BdKE=";
      };
      xcodeenv = import (nixpkgs + "/pkgs/development/mobile/xcodeenv") {inherit (pkgs) callPackage;};
      androidCustomPackage = android-nixpkgs.sdk.${system} (
        # show all potential values with
        # nix flake show github:tadfisher/android-nixpkgs
        sdkPkgs:
          with sdkPkgs; [
            cmdline-tools-latest
            # cmdline-tools-17-0
            build-tools-33-0-1
            build-tools-34-0-0
            build-tools-35-0-0
            ndk-23-1-7779620
            ndk-26-1-10909125
            ndk-28-0-13004108
            platform-tools
            emulator
            platforms-android-33
            platforms-android-34
            platforms-android-35
            system-images-android-34-aosp-atd-arm64-v8a #basic image, 40% faster
            system-images-android-34-google-apis-arm64-v8a #google branded
            system-images-android-34-google-apis-playstore-arm64-v8a #google branded with playstore installed
            system-images-android-35-aosp-atd-arm64-v8a #basic image, 40% faster
            system-images-android-35-google-apis-arm64-v8a #google branded
            system-images-android-35-google-apis-playstore-arm64-v8a #google branded with playstore installed
          ]
      );
      pinnedJDK = pkgs.jdk17_headless;
      # pinnedFlutter = pkgs.flutter;
      commonInputs = [
        rinf
        rustToolchain
        androidCustomPackage
        pinnedJDK
        # pinnedFlutter
      ];
      linuxInputs = [];
      darwinInputs = [
        (xcodeenv.composeXcodeWrapper {versions = ["16.2"];})
        pkgs.cocoapods
      ];
    in {
      devShells.default = mkShellNoCC {
        nativeBuildInputs =
          commonInputs
          ++ (
            if pkgs.stdenv.isLinux
            then linuxInputs
            else []
          )
          ++ (
            if pkgs.stdenv.isDarwin
            then darwinInputs
            else []
          );

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
        # FLUTTER_ROOT = "${pinnedFlutter}";

        shellHook = ''
          unset DEVELOPER_DIR
          unset SDKROOT

          mkdir -p ${localToolchainPath}

          # installs flutter locally, if not there already
          ${localFlutter.unpack_flutter}/bin/unpack_flutter
          export PATH="${localFlutterPath}/flutter/bin:$PATH"
        '';
      };
    });
}

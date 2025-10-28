{
  inputs,
  system,
  pkgs,
}: rec {
  inherit pkgs;
  rinf = pkgs.callPackage ./rinf.nix {};
  localToolchainPath = "$PWD/.toolchain";
  localFlutterPath = "${localToolchainPath}/flutter-local";
  localFlutter = pkgs.callPackage ./flutter.nix {inherit localFlutterPath;};
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
  rustToolchain = with inputs.fenix.packages.${system};
    combine ((with stable; [
        cargo
        rustc
        rust-src
        rust-analyzer
        clippy
        rustfmt
      ])
      ++ builtins.map (x: targets.${x}.stable.rust-std) targetPlatforms);

  xcodeenv = import (inputs.nixpkgs + "/pkgs/development/mobile/xcodeenv") {inherit (pkgs) callPackage;};
  androidCustomPackage = inputs.android-nixpkgs.sdk.${system} (
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
  rustupOnly = pkgs.stdenv.mkDerivation {
    name = "rustup";
    unpackPhase = ''
      mkdir -p "$out/bin"
      cp -r "${pkgs.rustup}/bin/rustup" "$out/bin"
      cp -r "${pkgs.rustup}/nix-support" $out
      cp -r "${pkgs.rustup}/share" $out
    '';
  };
  commonInputs = [
    rinf
    rustToolchain
    rustupOnly
    androidCustomPackage
    pinnedJDK
  ];
}

{
  pkgs,
  rinf,
  pinnedFlutter,
  ...
}: let
  widgetbookSrc = pkgs.stdenv.mkDerivation {
    pname = "efael-app-widgetbook-src";
    version = "0.1.0";
    src = ./.;
    nativeBuildInputs = [
      rinf
    ];
    buildPhase = ''
      cp -r "$src/." .
      rinf gen
      mkdir -p $out
      cp -r . $out
    '';
  };
in
  (
    pinnedFlutter.buildFlutterApplication {
      pname = "efael-app-widgetbook";
      version = widgetbookSrc.version;

      src = widgetbookSrc;
      autoPubspecLock = ./widgetbook/pubspec.lock;
      sourceRoot = "widgetbook";
      flutterBuildFlags = [
        "--base-href"
        "/app/"
      ];

      targetFlutterPlatform = "web";
    }
  ).overrideAttrs ({packageConfig, ...}: let
    sourceRoot = "${widgetbookSrc.name}/widgetbook";
  in {
    # these overrides needed for properly resolving pub dependencies
    packageConfig = packageConfig.overrideAttrs (_: {
      inherit sourceRoot;
    });
    inherit sourceRoot;
  })

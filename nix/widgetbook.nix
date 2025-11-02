{
  pinnedFlutter,
  appSrc,
  ...
}: let
in
  pinnedFlutter.buildFlutterApplication {
    pname = "efael-app-widgetbook";
    version = appSrc.version;

    src = appSrc;

    autoPubspecLock = ../pubspec.lock;

    flutterBuildFlags = [
      "--base-href"
      "/app/"
      "--dart-define=WIDGETBOOK=enable"
    ];

    targetFlutterPlatform = "web";
  }

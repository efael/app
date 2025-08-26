{
  pkgs ? import <nixpkgs> {},
  localFlutterPath,
}:
# Downloads flutter into a local directory (passed as local_flutter_path) and returns the bin path so the calling shellHook can set it to the PATH
# call (e.g. in ShellHook) with
#   ${flutter-local.unpack_flutter}/bin/unpack_flutter
#   export PATH="${local_flutter_path}/flutter/bin:$PATH"
# add a new flutter version:
# check the url in https://docs.flutter.dev/release/archive?tab=macos
# leave `hash = ""` and run `nix develop`. The error message will tell the correct hash value.
rec {
  flutterVersion = "3.35.2";
  latestVersion = flutterVersion;
  desiredVersion =
    if (flutterVersion == null || flutterVersion == "latest")
    then latestVersion
    else flutterVersion;

  flutterSource =
    pkgs.fetchurl
    (
      if pkgs.stdenv.isDarwin
      then
        if pkgs.stdenv.isAarch64
        then {
          url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.35.2-stable.zip";
          hash = "sha256-e/z2g++AS186UjaY9SwHD2P3qC8+ggzphOh4BUDG6JE=";
        }
        else {}
      else if pkgs.stdenv.isLinux
      then {}
      else {}
    );

  unpack_flutter = pkgs.writeShellApplication {
    name = "unpack_flutter";
    runtimeInputs = with pkgs; [
      unzip
    ];

    text = ''
      flutter_bin_dir="${localFlutterPath}"/flutter/bin
      flutter_bin_file="$flutter_bin_dir"/flutter

      echo "flutter needs local installation? ..."
      if [ -f "$flutter_bin_file" ]; then
        local_flutter_version=$( $flutter_bin_file --version | grep -oP 'Flutter \K.*(?= • channel)')
        if [ "$local_flutter_version" = "${desiredVersion}" ]; then
          echo "flutter $local_flutter_version is already installed locally in '${localFlutterPath}'"
          install=false
        else
          echo "flutter is already installed locally, but the installed version '$local_flutter_version' is not the same as requested version '${desiredVersion}'.  Uninstalling..."
          rm -rf "${localFlutterPath}"
          install=true
        fi
      else
        install=true
      fi
      if [ "$install" = "true" ]; then
        echo "... installing flutter version '${desiredVersion}' locally in '${localFlutterPath}'"
        unzip "${flutterSource}" -d "${localFlutterPath}"
        echo "installed flutter version '${desiredVersion}' to '${localFlutterPath}'"
      fi
    '';
  };
}

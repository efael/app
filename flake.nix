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
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
      attrs = import ./nix/attrs.nix {inherit inputs pkgs system;};
    in {
      packages = {
        widgetbook = pkgs.callPackage ./nix/widgetbook.nix attrs;
      };
      devShells.default =
        if pkgs.stdenv.isLinux
        then pkgs.callPackage ./nix/shell_linux.nix attrs
        else if pkgs.stdenv.isDarwin
        then pkgs.callPackage ./nix/shell_darwin.nix attrs
        else pkgs.mkShell {};
    });
}

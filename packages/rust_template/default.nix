{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-pIzuccdlBZUzjmD+niZPbLu/Brh6xHx6uXkM6/vgMSA=";
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-ZOIqujg9SLQMSWQffa0W78QOgmgOnhh+hWhHK8IC1Qs=";
  doCheck = pkgs.stdenv.isLinux;
  env.RUSTFLAGS = "-D warnings";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf ./.;
  preCheck = ''
    export CANONICALIZATION_ROOT=${../../.}
  '';
  src = ./.;
  version = "0.0.0";
}

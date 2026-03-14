{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-ZOIqujg9SLQMSWQffa0W78QOgmgOnhh+hWhHK8IC1Qs=";
  env.RUSTFLAGS = "-D warnings";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.clippy
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf ./.;
  postInstall = ''
    cargo clippy -- -D warnings
    CANONICALIZATION_ROOT=${../../.} cargo test
    CANONICALIZATION_ROOT=${../../.} DEBUG=1 $out/bin/${pname}
  '';
  preCheck = ''
    export CANONICALIZATION_ROOT=${../../.}
  '';
  src = ./.;
  version = "0.0.0";
}

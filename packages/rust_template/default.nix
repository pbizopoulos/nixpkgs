{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-eYbFGvryzvF0Px0Iyfaws3fwWbSKUn/montDzNymyBc=";
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
    DEBUG=1 $out/bin/${pname}
  '';
  src = ./.;
  version = "0.0.0";
}

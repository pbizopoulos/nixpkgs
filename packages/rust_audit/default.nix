{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) rustPlatform;
  auditing-tools = [
    pkgs.cargo
    pkgs.cargo-audit
    pkgs.cargo-bloat
    pkgs.cargo-deny
    pkgs.cargo-flamegraph
    pkgs.cargo-geiger
    pkgs.cargo-llvm-cov
    pkgs.nix
    pkgs.rustc
    pkgs.stdenv.cc
  ];
in
rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-UgC4azDA7zjim6vpvG3lFNS6JmcRQx6LiyxhHruQD2U=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.pkg-config
  ];
  pname = "rust_audit";
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${pkgs.lib.makeBinPath auditing-tools} \
      --set RUST_SRC_PATH ${pkgs.rustPlatform.rustLibSrc}
  '';
  src = ./.;
  version = "0.1.0";
}

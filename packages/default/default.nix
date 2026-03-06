{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) rustPlatform;
in
rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-ecBXTlmVnY8RE8tgVrJPaGdc0YNQcLTKQsQClTMDbNY=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.makeWrapper
    pkgs.pkg-config
    rustPlatform.bindgenHook
  ];
  pname = "default";
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.git
          pkgs.nix
        ]
      }
  '';
  src = ./.;
  version = "0.1.0";
}

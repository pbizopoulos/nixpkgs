{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) rustPlatform;
in
rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-R3cJZIt3pbFznqQzl4dIlehqwPdeYyqN1yy8M6WftMc=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.makeWrapper
    pkgs.pkg-config
    rustPlatform.bindgenHook
  ];
  pname = "check_repository_directory_structure";
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.git
        ]
      }
  '';
  src = ./.;
  version = "0.1.0";
}

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
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
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf ./.;
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.git
          pkgs.openssl
          pkgs.zlib
        ]
      }
  '';
  src = ./.;
  version = "0.1.0";
}

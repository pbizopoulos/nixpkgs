{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.git
    pkgs.imagemagick
  ];
  cargoHash = "sha256-Rn7HzfOe4DH/dLlSDHQeHIcHOiqPzjLTRKnEObV6RZk=";
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "git_inverse";
  postInstall = ''
    wrapProgram $out/bin/git_inverse \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.git
          pkgs.imagemagick
        ]
      }
  '';
  src = ./.;
  version = "0.1.0";
}

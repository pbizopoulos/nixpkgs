{
  pkgs ? import <nixpkgs> { },
}:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "git_inverse";
  version = "0.1.0";
  src = ./.;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  buildInputs = [
    pkgs.git
    pkgs.imagemagick
  ];
  postInstall = ''
    wrapProgram $out/bin/git_inverse \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.imagemagick ]}
  '';
  cargoHash = "sha256-Rn7HzfOe4DH/dLlSDHQeHIcHOiqPzjLTRKnEObV6RZk=";
}

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
  cargoHash = "sha256-zv0jYne/uaSDuxf0m/3pSBeCNHCMp2VhAa+gOmS6KuU=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.makeWrapper
    pkgs.pkg-config
    rustPlatform.bindgenHook
  ];
  pname = builtins.baseNameOf src;
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git ]}
  '';
  src = ./.;
  version = "0.1.0";
}

{
  pkgs ? import <nixpkgs> { },
}:
let
  auditing-tools = [
    pkgs.nix
    pkgs.nodejs
  ];
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.nodejs ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${./main.js} $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${pkgs.lib.makeBinPath auditing-tools}
  '';
  meta = {
    mainProgram = pname;
    platforms = pkgs.lib.platforms.linux;
  };
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "javascript_audit";
  src = ./.;
  version = "0.0.0";
}

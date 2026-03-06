{ pkgs ? import <nixpkgs> { }
,
}:
let
  auditing-tools = [
    pkgs.go
    pkgs.govulncheck
    pkgs.gosec
    pkgs.nix
  ];
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.go ];
  buildPhase = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH=$TMPDIR/go
    go build -o ${pname} main.go
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${pkgs.lib.makeBinPath auditing-tools}
  '';
  meta = {
    mainProgram = pname;
    platforms = pkgs.lib.platforms.linux;
  };
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "go_audit";
  src = ./src;
  version = "0.0.0";
}

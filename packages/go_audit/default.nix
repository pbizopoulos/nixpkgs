{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.go
  ];
  buildPhase = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH=$TMPDIR/go
    go build -o ${pname} main.go
  '';
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.go
          pkgs.gosec
          pkgs.govulncheck
          pkgs.nix
        ]
      }
  '';
  meta = {
    mainProgram = pname;
    platforms = pkgs.lib.platforms.linux;
  };
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./src;
  version = "0.0.0";
}

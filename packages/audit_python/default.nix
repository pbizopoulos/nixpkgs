{
  pkgs ? import <nixpkgs> { },
}:
let
  python = pkgs.python313.withPackages (ps: [
    ps.coverage
    ps.scalene
    ps.typer
    ps.vulture
  ]);
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ python ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.py $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nix
          python
        ]
      }
  '';
  meta = {
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

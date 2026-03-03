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
    cp main.py $out/bin/py-audit
    chmod +x $out/bin/py-audit
    wrapProgram $out/bin/py-audit \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nix
          python
        ]
      }
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

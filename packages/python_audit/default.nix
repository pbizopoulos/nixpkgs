{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    python
  ];
  installPhase = ''
    install -Dm755 main.py $out/bin/${pname}
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
    platforms = [
      "x86_64-linux"
    ];
  };
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  python = pkgs.python313.withPackages (ps: [
    ps.coverage
    ps.scalene
    ps.typer
  ]);
  src = ./.;
  version = "0.0.0";
}

{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ (pkgs.agda.withPackages (p: [ p.standard-library ])) ];
  buildPhase = ''
    agda --compile Main.agda
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp Main $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

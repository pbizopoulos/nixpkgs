{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.julia-bin ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.jl $out/bin/${pname}.jl
    makeWrapper ${pkgs.julia-bin}/bin/julia $out/bin/${pname} \
      --add-flags "$out/bin/${pname}.jl"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "julia_template";
  src = ./.;
  version = "0.0.0";
}

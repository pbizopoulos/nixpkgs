{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.R ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.R $out/bin/${pname}.R
    makeWrapper ${pkgs.R}/bin/Rscript $out/bin/${pname} \
      --add-flags "$out/bin/${pname}.R"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "r_template";
  src = ./.;
  version = "0.0.0";
}

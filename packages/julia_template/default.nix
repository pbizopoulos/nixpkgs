{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    install -Dm644 main.jl $out/share/main.jl
    makeWrapper ${pkgs.julia-bin}/bin/julia $out/bin/${pname} \
      --add-flags "--warn-overwrite=yes --warn-scope=yes $out/share/main.jl"
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

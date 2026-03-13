{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  pname = baseNameOf ./.;
  version = "0.0.0";
  src = ./.;

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  installPhase = ''
    install -Dm644 main.jl $out/share/main.jl
    makeWrapper ${pkgs.julia-bin}/bin/julia $out/bin/${pname} \
      --add-flags "--warn-overwrite=yes --warn-scope=yes $out/share/main.jl"
  '';

  meta.mainProgram = pname;
}

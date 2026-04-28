{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    latexmk -pdf ms.tex
  '';
  doInstallCheck = pkgs.stdenv.isLinux;
  installCheckPhase = ''
    runHook preInstallCheck
    test -f "$out/ms.pdf"
    test -s "$out/ms.pdf"
    runHook postInstallCheck
  '';
  installPhase = ''
    install -Dm644 ms.pdf $out/ms.pdf
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.texliveFull
  ];
  pname = baseNameOf ./.;
  src = ./.;
  strictDeps = true;
  version = "0.0.0";
}

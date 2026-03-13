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
    install -Dm644 main.exs $out/share/main.exs
    makeWrapper ${pkgs.elixir}/bin/elixir $out/bin/${pname} \
      --add-flags "$out/share/main.exs"
  '';

  meta.mainProgram = pname;
}

{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.elixir ];
  installPhase = ''
    mkdir -p $out/share/elixir
    cp main.exs $out/share/elixir/
    mkdir -p $out/bin
    makeWrapper ${pkgs.elixir}/bin/elixir $out/bin/${pname} \
      --add-flags "$out/share/elixir/main.exs"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

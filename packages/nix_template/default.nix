{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.nix
  ];
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.nix}/bin/nix-instantiate --eval --expr 'import $out/share/nix/main.nix { }' | tr -d '\"'" >> $out/bin/${pname}
    mkdir -p $out/share/nix
    cp main.nix $out/share/nix/main.nix
    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

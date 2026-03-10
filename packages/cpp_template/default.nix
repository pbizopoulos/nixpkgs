{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.nlohmann_json
    ];
    buildPhase = "g++ -o ${pname} main.cpp -O3 -Wall -Wextra -Werror";
    installPhase = ''
      mkdir -p $out/bin
      cp -f ${pname} $out/bin/
      chmod 755 $out/bin/${pname}
      '';
    meta.mainProgram = pname;
    pname = "cpp_template";
    src = ./.;
    version = "0.0.0";
  }

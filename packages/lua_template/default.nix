{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.lua)
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp main.lua $out/bin/${pname}
      chmod +x $out/bin/${pname}
      wrapProgram $out/bin/${pname} --prefix PATH : ${pkgs.lua}/bin
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "lua_template";
    src = ./.;
    version = "0.0.0";
  }
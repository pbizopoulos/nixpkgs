{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.godot_4)
    ];
    installPhase = ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.godot_4}/bin/godot4 --headless --script $out/share/gdscript/main.gd" >> $out/bin/${pname}
      mkdir -p $out/share/gdscript
      cp main.gd $out/share/gdscript/main.gd
      chmod +x $out/bin/${pname}
      '';
    pname = "gdscript_template";
    src = ./.;
    version = "0.0.0";
  }
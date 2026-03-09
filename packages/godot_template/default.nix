{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [ pkgs.godot_4 ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.godot_4}/bin/godot4 --path $out/lib/${pname}" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "godot_template";
  src = ./.;
  version = "0.0.0";
}

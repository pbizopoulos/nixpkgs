{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
in
pkgs.stdenv.mkDerivation {
  inherit pname;
  src = ./.;
  version = "0.0.0";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/lib/${pname}
    cp -r . $out/lib/${pname}
    mkdir -p $out/bin
    cat <<EOF > $out/bin/${pname}
#!/bin/sh
exec ${pkgs.godot_4}/bin/godot4 --headless --path $out/lib/${pname}
EOF
    chmod +x $out/bin/${pname}
  '';
}

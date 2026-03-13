{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.micropython
  ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/${pname}
    cp main.py $out/lib/${pname}/main.py
    cat <<EOF > $out/bin/${pname}
#!/bin/sh
exec ${pkgs.micropython}/bin/micropython $out/lib/${pname}/main.py
EOF
    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.opentofu
  ];
  installPhase = ''
        mkdir -p $out/bin $out/share
        cp main.tf $out/share/main.tf
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      ${pkgs.opentofu}/bin/tofu fmt -check $out/share/main.tf > /dev/null && echo "test ... ok"
    else
      cat $out/share/main.tf
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

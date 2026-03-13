{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.opentofu
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    ${pkgs.opentofu}/bin/tofu fmt -check ${./main.tf} > /dev/null && cat ${./main.tf}
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

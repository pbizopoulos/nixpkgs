{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.bash ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    if [ "\$DEBUG" == "1" ]; then
      echo "test ... ok"
    else
      for i in \$(seq 1 100); do
        if [ \$((i % 15)) -eq 0 ]; then
          echo -e "''${RED}FizzBuzz''${NC}"
        elif [ \$((i % 3)) -eq 0 ]; then
          echo -e "''${GREEN}Fizz''${NC}"
        elif [ \$((i % 5)) -eq 0 ]; then
          echo -e "''${BLUE}Buzz''${NC}"
        else
          echo "\$i"
        fi
      done
    fi
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = "gleam_template";
  src = ./.;
  version = "0.0.0";
}

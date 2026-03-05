{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.nix
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<'EOF' > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "$DEBUG" == "1" ]; then
      nix-instantiate --eval --expr 'import ${./.}/main.nix { debug = true; }' | tr -d '"'
    else
      nix-instantiate --eval --expr 'import ${./.}/main.nix { }' | tr -d '"'
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

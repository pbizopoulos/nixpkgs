{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  checkPhase = ''
    export NIX_STATE_DIR=$TMPDIR
    nix-instantiate --eval --expr 'import ${./.}/main.nix { }' --readonly-mode
  '';
  doCheck = true;
  installPhase = ''
    mkdir -p $out/bin
    cat <<EOF > $out/bin/${pname}
    #!/bin/sh
    export NIX_STATE_DIR=\$TMPDIR
    exec ${pkgs.nix}/bin/nix-instantiate --eval --expr 'import ${./.}/main.nix { }' --readonly-mode | tr -d '"'
    EOF
    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.nix
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

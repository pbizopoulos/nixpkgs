{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.cue ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    ${pkgs.cue}/bin/cue export --out text ${./main.cue}
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = "cue_template";
  src = ./.;
  version = "0.0.0";
}

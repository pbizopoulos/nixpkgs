{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.cue ];
  installPhase = ''
        mkdir -p $out/lib/cue
        cp main.cue $out/lib/cue/
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      # Use a temporary file to avoid 'no packages matched' error
      echo "x: 1 + 1" > /tmp/test.cue
      ${pkgs.cue}/bin/cue eval /tmp/test.cue | grep -q 'x: 2' && echo "test math ... ok" || (echo "test math failed"; exit 1)
      rm /tmp/test.cue
    else
      ${pkgs.cue}/bin/cue export --out text $out/lib/cue/main.cue
    fi
    EOF
        chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

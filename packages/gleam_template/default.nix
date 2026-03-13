{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
  src = ./.;
  script = pkgs.writeShellScriptBin pname ''
    export PATH="${pkgs.lib.makeBinPath [ pkgs.gleam pkgs.erlang pkgs.coreutils ]}:$PATH"
    export HOME=''${TMPDIR:-/tmp}
    PROJECT_DIR=$(mktemp -d)
    cp -r ${src}/. $PROJECT_DIR/
    cd $PROJECT_DIR
    chmod -R +w .
    exec gleam run
  '';
in
script

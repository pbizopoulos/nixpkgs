{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  export PATH="${pkgs.lib.makeBinPath [ pkgs.gleam pkgs.erlang pkgs.coreutils ]}:$PATH"
  export HOME=''${TMPDIR:-/tmp}
  PROJECT_DIR=$(mktemp -d)
  cp -r ${./.}/. $PROJECT_DIR/
  cd $PROJECT_DIR
  chmod -R +w .
  exec gleam run
''

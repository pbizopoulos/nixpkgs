{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  export PATH="${
    pkgs.lib.makeBinPath [
      pkgs.coreutils
      pkgs.erlang
      pkgs.gleam
    ]
  }:$PATH"
  export NO_COLOR=1
  export GLEAM_COLOR=never
  export HOME=''${TMPDIR:-/tmp}
  PROJECT_DIR=$(mktemp -d)
  cp -r ${./.}/. $PROJECT_DIR/
  cd $PROJECT_DIR
  chmod -R +w .
  gleam run >/tmp/gleam_template.log 2>&1 || { cat /tmp/gleam_template.log; exit 1; }
''

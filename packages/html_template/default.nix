{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  if [ "$DEBUG" = "1" ]; then
    echo "debug mode: skipping http-server"
    exit 0
  fi
  exec ${pkgs.nodePackages.http-server}/bin/http-server ${./.} "$@"
''

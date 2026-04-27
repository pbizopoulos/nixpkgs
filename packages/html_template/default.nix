{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  if [ "$DEBUG" != "1" ]; then
    exec ${pkgs.http-server}/bin/http-server ${./.} "$@"
  fi
''

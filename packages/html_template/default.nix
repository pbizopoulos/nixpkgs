{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.nodePackages.http-server}/bin/http-server ${./.} "$@"
''

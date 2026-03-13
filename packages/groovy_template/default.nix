{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.groovy}/bin/groovy ${./.}/main.groovy "$@"
''

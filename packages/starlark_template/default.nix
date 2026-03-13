{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.starlark}/bin/starlark ${./.}/main.star "$@"
''

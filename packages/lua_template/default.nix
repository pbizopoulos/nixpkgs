{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.lua}/bin/lua -W ${./.}/main.lua "$@"
''

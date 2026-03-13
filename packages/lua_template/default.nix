{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.lua5_4}/bin/lua -W ${./.}/main.lua "$@"
''

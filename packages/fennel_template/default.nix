{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.luaPackages.fennel}/bin/fennel ${./.}/main.fnl "$@"
''

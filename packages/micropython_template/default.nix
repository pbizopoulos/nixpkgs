{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.micropython}/bin/micropython ${./.}/main.py "$@"
''

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.dhall}/bin/dhall text --file ${./.}/main.dhall
''

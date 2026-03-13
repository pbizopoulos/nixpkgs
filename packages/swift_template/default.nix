{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.swift}/bin/swift -warnings-as-errors ${./.}/main.swift "$@"
''

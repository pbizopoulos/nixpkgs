{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.ruby}/bin/ruby ${./.}/main.rb "$@"
''

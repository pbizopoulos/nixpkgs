{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.ruby}/bin/ruby -w ${./.}/main.rb "$@"
''

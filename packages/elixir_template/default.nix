{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.elixir}/bin/elixir ${./.}/main.exs "$@"
''

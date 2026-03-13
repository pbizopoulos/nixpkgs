{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.julia-bin}/bin/julia --warn-overwrite=yes --warn-scope=yes ${./.}/main.jl "$@"
''

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.julia-bin}/bin/julia --warn-overwrite=yes --warn-unused-variables=yes ${./.}/main.jl "$@"
''

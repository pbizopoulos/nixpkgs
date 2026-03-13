{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.julia-bin}/bin/julia ${./.}/main.jl "$@"
''

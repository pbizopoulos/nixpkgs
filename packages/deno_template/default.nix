{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.deno}/bin/deno run --allow-net ${./.}/main.ts "$@"
''

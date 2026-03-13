{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.nix}/bin/nix-instantiate --eval --expr 'import ${./.}/main.nix { }' | tr -d '"'
''

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.go-jsonnet}/bin/jsonnet ${./.}/main.jsonnet
''

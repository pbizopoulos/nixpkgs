{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  ${pkgs.opentofu}/bin/tofu fmt -check ${./.}/main.tf > /dev/null && cat ${./.}/main.tf
''

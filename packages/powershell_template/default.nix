{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  exec ${pkgs.powershell}/bin/pwsh -File ${./.}/main.ps1 "$@"
''

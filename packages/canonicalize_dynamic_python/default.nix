{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellApplication {
  name = builtins.baseNameOf ./.;
  runtimeInputs = [
    pkgs.python312Packages.coverage
    pkgs.python312Packages.scalene
  ];
  text = builtins.readFile ./main.sh;
}

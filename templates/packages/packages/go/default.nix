{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildGoModule rec {
  pname = builtins.baseNameOf src;
  src = ./.;
  vendorHash = "";
  version = "0.0.0";
}

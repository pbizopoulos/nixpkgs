{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildGoModule rec {
  pname = baseNameOf ./.;
  src = ./.;
  vendorHash = null;
  version = "0.0.0";
}

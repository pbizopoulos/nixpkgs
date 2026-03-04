{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildGoModule rec {
  pname = baseNameOf src;
  postInstall = "mv $out/bin/go-hello $out/bin/${pname}";
  src = ./.;
  vendorHash = null;
  version = "0.0.0";
}

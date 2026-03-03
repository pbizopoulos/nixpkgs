{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage {
  buildAndTestSubdir = "schemaui-cli";
  cargoHash = "sha256-wH1/8qs1inubnDAJnLyZY4g7rHXC6Yzdu+IWPO9A0Dc=";
  doCheck = false;
  pname = "schemaui";
  src = pkgs.fetchFromGitHub {
    owner = "YuniqueUnic";
    repo = "schemaui";
    rev = "bbb917f4e4aff2611aa33b2eef11f30262368815";
    sha256 = "sha256-fLInoUQYxv8ilZWTWTFSKdKX7rgaoNe8dNMH5+AIGJU=";
  };
  version = "0.4.3";
}

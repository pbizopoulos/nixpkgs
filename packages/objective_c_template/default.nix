{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    clang -o ${pname} main.m -O3 -Wall -Wextra -Werror -Wformat=2 -fsanitize=address,undefined -fstack-protector-strong -fstack-clash-protection -D_FORTIFY_SOURCE=3 -Wl,-z,relro,-z,now -Wl,-z,noexecstack
  '';
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
  '';
  checkPhase = ''
    ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.clang
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

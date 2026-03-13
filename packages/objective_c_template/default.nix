{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    clang -o ${pname} main.m -O3 -Wall -Wextra -Werror -Wformat=2 -fsanitize=address,undefined -fstack-protector-strong -fstack-clash-protection -D_FORTIFY_SOURCE=3 -Wl,-z,relro,-z,now -Wl,-z,noexecstack
  '';
  checkPhase = ''
    clang-tidy main.m -- -I${pkgs.stdenv.cc.libc.dev}/include -I${pkgs.lib.getDev pkgs.stdenv.cc.cc}/include
    ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.clang
  ];
  nativeCheckInputs = [
    pkgs.clang-tools
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.binutils
    pkgs.nasm
  ];
  buildPhase = ''
    nasm -f elf64 -o main.o main.asm
    ld -o ${pname} main.o
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -f ${pname} $out/bin/
    chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nlohmann_json
  ];
  buildPhase = ''
    g++ -o ${pname} main.cpp -O3 -std=c++20 \
    -Waddress \
    -Waggressive-loop-optimizations \
    -Wall \
    -Walloc-zero \
    -Walloca \
    -Wattribute-alias \
    -Wattributes \
    -Wbuiltin-declaration-mismatch \
    -Wbuiltin-macro-redefined \
    -Wcast-align \
    -Wcast-align=strict \
    -Wcast-qual \
    -Wconversion \
    -Wcoverage-mismatch \
    -Wcpp \
    -Wdate-time \
    -Wdeprecated \
    -Wdeprecated-declarations \
    -Wdisabled-optimization \
    -Wdiv-by-zero \
    -Wdouble-promotion \
    -Wduplicated-branches \
    -Wduplicated-cond \
    -Wextra \
    -Wfloat-equal \
    -Wformat-signedness \
    -Wfree-nonheap-object \
    -Whsa \
    -Wif-not-aligned \
    -Wignored-attributes \
    -Wimport \
    -Winline \
    -Winvalid-memory-model \
    -Winvalid-pch \
    -Wlogical-op \
    -Wlto-type-mismatch \
    -Wmissing-declarations \
    -Wmissing-include-dirs \
    -Wmultichar \
    -Wnull-dereference \
    -Wodr \
    -Woverflow \
    -Wpacked \
    -Wpacked-bitfield-compat \
    -Wpedantic \
    -Wpointer-compare \
    -Wpragmas \
    -Wreturn-local-addr \
    -Wscalar-storage-order \
    -Wshadow \
    -Wshift-count-negative \
    -Wshift-count-overflow \
    -Wshift-negative-value \
    -Wsizeof-array-argument \
    -Wstack-protector \
    -Wstrict-aliasing \
    -Wstrict-overflow \
    -Wsuggest-final-methods \
    -Wsuggest-final-types \
    -Wsuggest-override \
    -Wswitch-bool \
    -Wswitch-default \
    -Wswitch-enum \
    -Wswitch-unreachable \
    -Wsync-nand \
    -Wtrampolines \
    -Wundef \
    -Wunreachable-code \
    -Wunsafe-loop-optimizations \
    -Wunused-macros \
    -Wunused-result \
    -Wvarargs \
    -Wvector-operation-performance \
    -Wvla \
    -Wwrite-strings \
    -Wformat=2 \
    -fsanitize=address,undefined \
    -fstack-protector-strong \
    -fstack-clash-protection \
    -D_FORTIFY_SOURCE=3 \
    -Wl,-z,relro,-z,now \
    -Wl,-z,noexecstack
  '';
  checkPhase = ''
    clang-tidy main.cpp -- -std=c++20 -I${pkgs.stdenv.cc.libc.dev}/include -I${pkgs.lib.getDev pkgs.stdenv.cc.cc}/include -I${pkgs.nlohmann_json}/include
    cppcheck --enable=all --error-exitcode=1 --language=c++ --suppress=missingIncludeSystem .
    ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.clang-tools
    pkgs.cppcheck
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}

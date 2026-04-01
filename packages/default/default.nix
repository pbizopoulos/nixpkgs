{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
  runtimePath = pkgs.lib.makeBinPath [
    pkgs.cargo
    pkgs.cargo-llvm-cov
    pkgs.cargo-mutants
    pkgs.coreutils
    pkgs.llvmPackages.clang
    pkgs.llvmPackages.llvm
    pkgs.pkg-config
    pkgs.rustc
    pkgs.stdenv.cc
  ];
in
pkgs.rustPlatform.buildRustPackage rec {
  inherit pname;
  buildInputs = [ ];
  cargoHash = "sha256-ZOIqujg9SLQMSWQffa0W78QOgmgOnhh+hWhHK8IC1Qs=";
  doCheck = pkgs.stdenv.isLinux;
  env.RUSTFLAGS = "-D warnings";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  postInstall = ''
        mv "$out/bin/${pname}" "$out/bin/.${pname}-wrapped"
        cat > "$out/bin/${pname}" <<'EOF'
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export PATH='${runtimePath}':"$PATH"
    export LIBCLANG_PATH='${pkgs.llvmPackages.libclang.lib}/lib'
    export LLVM_COV='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-cov"}'
    export LLVM_PROFDATA='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-profdata"}'
    is_package_root() {
      local candidate="$1"
      [ -f "$candidate/Cargo.toml" ] && [ -f "$candidate/src/main.rs" ]
    }
    resolve_source_root() {
      local workspace_package_root="$PWD/packages/${pname}"
      if is_package_root "$workspace_package_root"; then
        printf '%s\n' "$workspace_package_root"
        return 0
      fi
      if is_package_root "$PWD"; then
        printf '%s\n' "$PWD"
        return 0
      fi
      return 1
    }
    if [ "''${DEBUG:-0}" = "1" ]; then
      if source_root="$(resolve_source_root)"; then
        coverage_dir="$source_root/coverage"
        export CANONICALIZATION_ROOT="$(realpath "$source_root/../..")"
        rm -rf "$coverage_dir"
        mkdir -p "$coverage_dir"
        cd "$source_root"
        cargo llvm-cov clean --workspace
        cargo llvm-cov --locked --no-report
        cargo llvm-cov report --html --output-dir "$coverage_dir/html"
        cargo llvm-cov report --summary-only | tee "$coverage_dir/summary.txt"
        mkdir -p "$source_root/tmp"
        rm -rf "$source_root/tmp/mutants.out"
        set +e
        cargo mutants --no-config --colors never --cap-lints true --jobs 1 --output "$source_root/tmp"
        mutation_status=$?
        set -e
        if [ "$mutation_status" -ne 0 ] && [ "$mutation_status" -ne 2 ]; then
          exit "$mutation_status"
        fi
        exit 0
      fi
    fi
    exec "@wrappedBin@" "$@"
    EOF
        substituteInPlace "$out/bin/${pname}" \
          --replace-fail "@wrappedBin@" "$out/bin/.${pname}-wrapped"
        chmod +x "$out/bin/${pname}"
  '';
  preCheck = ''
    export CANONICALIZATION_ROOT=${../../.}
  '';
  src = ./.;
  version = "0.0.0";
}

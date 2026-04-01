{
  pkgs ? import <nixpkgs> { },
}:
let
  debugGhc = pkgs.haskellPackages.ghcWithPackages haskellDeps;
  haskellDeps = ps: [
    ps.HUnit
    ps.aeson
    ps.base
    ps.bytestring
  ];
  pname = baseNameOf ./.;
  runtimePath = pkgs.lib.makeBinPath [
    debugGhc
    pkgs.coreutils
    pkgs.perl
  ];
  wrapperScript = pkgs.writeShellScript "${pname}-wrapper" ''
        set -euo pipefail
        export PATH='${runtimePath}':"$PATH"
        run_behavior_tests() {
          local binary="$1"
          local output
          output="$(DEBUG=1 "$binary")"
          [ "$output" = "test ... ok" ]
          output="$(env -u DEBUG "$binary")"
          [ "$output" = "Hello World" ]
        }
        compile_main() {
          local source_file="$1"
          local output_binary="$2"
          local output_dir="$3"
          "${debugGhc}/bin/ghc" \
            -outputdir "$output_dir" \
            -odir "$output_dir" \
            -hidir "$output_dir" \
            -o "$output_binary" \
            "$source_file" >/dev/null
        }
        run_mutation_tests() {
          local source_root="$1"
          local mutation_root="$source_root/tmp/mutants.out"
          local baseline_dir
          local mutation_dir
          local total=0
          local caught=0
          local missed=0
          mkdir -p "$source_root/tmp"
          rm -rf "$mutation_root"
          mkdir -p "$mutation_root"
          baseline_dir="$(mktemp -d)"
          compile_main "$source_root/Main.hs" "$baseline_dir/${pname}" "$baseline_dir"
          if ! run_behavior_tests "$baseline_dir/${pname}"; then
            rm -rf "$baseline_dir"
            echo "Baseline failed" | tee "$mutation_root/summary.txt"
            return 1
          fi
          while IFS='|' read -r mutation_name search replace; do
            [ -n "$mutation_name" ] || continue
            total=$((total + 1))
            mutation_dir="$(mktemp -d)"
            cp "$source_root/Main.hs" "$mutation_dir/Main.hs"
            SEARCH="$search" REPLACE="$replace" \
              perl -0pi -e 's/\Q$ENV{SEARCH}\E/$ENV{REPLACE}/' "$mutation_dir/Main.hs"
            compile_main "$mutation_dir/Main.hs" "$mutation_dir/${pname}" "$mutation_dir"
            if run_behavior_tests "$mutation_dir/${pname}"; then
              echo "MISSED $mutation_name" | tee -a "$mutation_root/summary.txt"
              missed=$((missed + 1))
            else
              echo "CAUGHT $mutation_name" | tee -a "$mutation_root/summary.txt"
              caught=$((caught + 1))
            fi
            rm -rf "$mutation_dir"
          done <<'MUTATIONS'
    debug-guard|Just "1"|_
    debug-output|test ... ok|test ... mutated
    release-output|Hello World|Hello Mutation
    MUTATIONS
          rm -rf "$baseline_dir"
          printf 'Mutants tested: %s, caught: %s, missed: %s\n' "$total" "$caught" "$missed" | tee -a "$mutation_root/summary.txt"
          return 0
        }
        is_package_root() {
          local candidate="$1"
          [ -f "$candidate/${pname}.cabal" ] && [ -f "$candidate/Main.hs" ]
        }
        find_workspace_root() {
          local current_dir="$PWD"
          while [ "$current_dir" != "/" ]; do
            if [ -f "$current_dir/flake.nix" ] && [ -d "$current_dir/packages" ]; then
              printf '%s\n' "$current_dir"
              return 0
            fi
            current_dir="$(dirname "$current_dir")"
          done
          return 1
        }
        resolve_source_root() {
          local workspace_root
          local workspace_package_root
          if workspace_root="$(find_workspace_root)"; then
            workspace_package_root="$workspace_root/packages/${pname}"
            if is_package_root "$workspace_package_root"; then
              printf '%s\n' "$workspace_package_root"
              return 0
            fi
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
            build_dir="$(mktemp -d)"
            trap 'rm -rf "$build_dir"' EXIT
            rm -rf "$coverage_dir"
            mkdir -p "$coverage_dir"
            cd "$source_root"
            "${debugGhc}/bin/ghc" \
              -fhpc \
              -hpcdir "$build_dir/hpc" \
              -outputdir "$build_dir" \
              -odir "$build_dir" \
              -hidir "$build_dir" \
              -o "$build_dir/${pname}" \
              Main.hs
            HPCTIXFILE="$coverage_dir/${pname}.tix" DEBUG=1 "$build_dir/${pname}"
            "${debugGhc}/bin/hpc" markup "$coverage_dir/${pname}.tix" \
              --hpcdir="$build_dir/hpc" \
              --destdir="$coverage_dir/html"
            "${debugGhc}/bin/hpc" report "$coverage_dir/${pname}.tix" \
              --hpcdir="$build_dir/hpc" | tee "$coverage_dir/summary.txt"
            run_mutation_tests "$source_root"
            exit 0
          fi
        fi
        rm -f "tmp/${pname}.tix"
        export HPCTIXFILE="tmp/${pname}.tix"
        exec "@wrappedBin@" "$@"
  '';
in
pkgs.haskellPackages.mkDerivation {
  inherit pname;
  executableHaskellDepends = haskellDeps pkgs.haskellPackages;
  license = pkgs.lib.licenses.mit;
  mainProgram = pname;
  postInstall = ''
    mv "$out/bin/${pname}" "$out/bin/.${pname}-wrapped"
    cp ${wrapperScript} "$out/bin/${pname}"
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail "@wrappedBin@" "$out/bin/.${pname}-wrapped"
    chmod +x "$out/bin/${pname}"
  '';
  src = ./.;
  version = "0.0.0";
}

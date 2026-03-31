{
  pkgs ? import <nixpkgs> { },
}:
let
  debugGhc = pkgs.haskellPackages.ghcWithPackages haskellDeps;
  haskellDeps = ps: [
    ps.HUnit
    ps.base
    ps.data-fix
    ps.hnix
    ps.prettyprinter
    ps.temporary
    ps.text
  ];
  pname = baseNameOf ./.;
  runtimePath = pkgs.lib.makeBinPath [
    debugGhc
    pkgs.bash
    pkgs.coreutils
  ];
in
pkgs.haskellPackages.mkDerivation rec {
  inherit pname;
  description = "Sorts attributes alphabetically, using dotted notation for attributes with sets or lists, and nested notation otherwise";
  executableHaskellDepends = haskellDeps pkgs.haskellPackages;
  executableToolDepends = [
    pkgs.makeWrapper
  ];
  license = pkgs.lib.licenses.mit;
  mainProgram = pname;
  postInstall = ''
        mv "$out/bin/${pname}" "$out/bin/.${pname}-wrapped"
        cat > "$out/bin/${pname}" <<'EOF'
    #!/nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-bash/bin/bash
    set -euo pipefail
    export PATH='${runtimePath}':"$PATH"
    is_package_root() {
      local candidate="$1"
      [ -f "$candidate/main.cabal" ] || return 1
      grep -Eq '^name:[[:space:]]+${pname}$' "$candidate/main.cabal"
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
        exit 0
      fi
    fi
    rm -f "tmp/${pname}.tix"
    export HPCTIXFILE="tmp/${pname}.tix"
    exec "@wrappedBin@" "$@"
    EOF
        substituteInPlace "$out/bin/${pname}" \
          --replace-fail '#!/nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-bash/bin/bash' '#!${pkgs.bash}/bin/bash' \
          --replace-fail "@wrappedBin@" "$out/bin/.${pname}-wrapped"
        chmod +x "$out/bin/${pname}"
  '';
  src = ./.;
  version = "0.0.0";
}

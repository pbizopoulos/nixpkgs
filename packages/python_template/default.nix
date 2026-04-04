{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
  pythonWithCoverage = pkgs.python313.withPackages (ps: [
    ps.coverage
  ]);
  runtimePath = pkgs.lib.makeBinPath [
    pkgs.coreutils
    pythonWithCoverage
  ];
  wrapperScript = pkgs.writeShellScript "${pname}-wrapper" ''
    set -euo pipefail
    export PATH='${runtimePath}':"$PATH"
    resolve_source_root() {
      local candidate
      local current_dir="$PWD"
      if [ -n "''${CANONICALIZATION_ROOT:-}" ]; then
        candidate="$CANONICALIZATION_ROOT/packages/${pname}"
        if [ -f "$candidate/main.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      fi
      while [ "$current_dir" != "/" ]; do
        candidate="$current_dir/packages/${pname}"
        if [ -f "$candidate/main.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
        current_dir="$(dirname "$current_dir")"
      done
      if [ -f "$PWD/main.py" ]; then
        printf '%s\n' "$PWD"
        return 0
      fi
      return 1
    }
    if [ "''${DEBUG:-0}" = "1" ]; then
      if source_root="$(resolve_source_root)"; then
        coverage_dir="$source_root/tmp/coverage"
        rm -rf "$coverage_dir"
        mkdir -p "$coverage_dir"
        cd "$source_root"
        export COVERAGE_FILE="$coverage_dir/.coverage"
        python3 -m coverage erase
        DEBUG=1 python3 -m coverage run --branch --include "$source_root/main.py" "$source_root/main.py"
        python3 -m coverage html -d "$coverage_dir/html"
        python3 -m coverage report | tee "$coverage_dir/summary.txt"
        exit 0
      fi
    fi
    exec "@wrappedBin@" "$@"
  '';
in
pkgs.stdenvNoCC.mkDerivation {
  inherit pname;
  installPhase = ''
    install -Dm755 ./main.py "$out/bin/.${pname}-wrapped"
    install -Dm755 ${wrapperScript} "$out/bin/${pname}"
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail "@wrappedBin@" "$out/bin/.${pname}-wrapped"
  '';
  meta.mainProgram = pname;
  src = ./.;
  version = "0.0.0";
}

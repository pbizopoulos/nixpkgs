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
      for candidate in "$PWD/packages/${pname}" "$PWD"; do
        if [ -f "$candidate/main.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done
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

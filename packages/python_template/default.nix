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
    is_package_root() {
      local candidate="$1"
      [ -f "$candidate/main.py" ]
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
pkgs.stdenv.mkDerivation {
  inherit pname;
  dontWrapPythonPrograms = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ./main.py $out/bin/.${pname}-wrapped
    cp ${wrapperScript} $out/bin/${pname}
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail "@wrappedBin@" "$out/bin/.${pname}-wrapped"
    chmod +x "$out/bin/${pname}" "$out/bin/.${pname}-wrapped"
  '';
  meta.mainProgram = pname;
  src = ./.;
  version = "0.0.0";
}

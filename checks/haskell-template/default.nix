{
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  debugGhc = pkgs.haskellPackages.ghcWithPackages (ps: [
    ps.HUnit
    ps.aeson
    ps.bytestring
  ]);
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      debugGhc
      pkgs.coreutils
    ];
    src = ../../packages/${name};
  }
  ''
    build_dir="$PWD"
    workspace="$build_dir/workspace"
    coverage_dir="$build_dir/coverage"
    hpcdir="$build_dir/hpc"
    export HOME="$build_dir"
    rm -rf "$workspace" "$coverage_dir" "$hpcdir"
    cp -R "$src" "$workspace"
    chmod -R u+w "$workspace"
    mkdir -p "$coverage_dir/html" "$hpcdir"
    cd "$workspace"
    "${debugGhc}/bin/ghc" \
      -fhpc \
      -hpcdir "$hpcdir" \
      -outputdir "$build_dir" \
      -odir "$build_dir" \
      -hidir "$build_dir" \
      -o "$build_dir/$name" \
      Main.hs
    HPCTIXFILE="$coverage_dir/$name.tix" DEBUG=1 "$build_dir/$name"
    "${debugGhc}/bin/hpc" markup "$coverage_dir/$name.tix" \
      --hpcdir="$hpcdir" \
      --destdir="$coverage_dir/html"
    "${debugGhc}/bin/hpc" report "$coverage_dir/$name.tix" \
      --hpcdir="$hpcdir" | tee "$coverage_dir/summary.txt"
    touch "$out"
  ''

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
    coverage_dir="$PWD/coverage"
    hpcdir="$PWD/hpc"
    export HOME="$PWD"
    rm -rf "$PWD/workspace" "$coverage_dir" "$hpcdir"
    mkdir -p "$PWD/workspace" "$coverage_dir/html" "$hpcdir"
    cp -R --no-preserve=mode "$src"/. "$PWD/workspace"
    cd "$PWD/workspace"
    "${debugGhc}/bin/ghc" \
      -fhpc \
      -hpcdir "$hpcdir" \
      -outputdir "$PWD" \
      -odir "$PWD" \
      -hidir "$PWD" \
      -o "$PWD/$name" \
      Main.hs
    HPCTIXFILE="$coverage_dir/$name.tix" DEBUG=1 "$PWD/$name"
    "${debugGhc}/bin/hpc" markup "$coverage_dir/$name.tix" \
      --hpcdir="$hpcdir" \
      --destdir="$coverage_dir/html"
    "${debugGhc}/bin/hpc" report "$coverage_dir/$name.tix" \
      --hpcdir="$hpcdir" | tee "$coverage_dir/summary.txt"
    touch "$out"
  ''

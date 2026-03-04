{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python312Packages.buildPythonPackage rec {
  installPhase = "mkdir -p $out/bin && cp ./main.py $out/bin/${pname}";
  meta.mainProgram = pname;
  pname = baseNameOf src;
  propagatedBuildInputs = [ ];
  pyproject = false;
  shellHook = ''
    cd $(git rev-parse --show-toplevel)/secrets || exit 1
    tmpfile=$(mktemp)
    nix run github:ryantm/agenix -- --decrypt secrets.age > "$tmpfile"
    export $(grep -v '^#' "$tmpfile" | xargs)
    rm "$tmpfile"
    cd - > /dev/null
  '';
  src = ./.;
  version = "0.0.0";
}

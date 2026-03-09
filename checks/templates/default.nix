{ inputs, pkgs, ... }:
let
  allPackages = inputs.self.packages.${pkgs.stdenv.system};
  templateNames = builtins.filter (name: pkgs.lib.hasSuffix "_template" name) (
    builtins.attrNames allPackages
  );
  templatePackages = map (name: allPackages.${name}) templateNames;
in
pkgs.runCommand "check-all-templates" { buildInputs = templatePackages; } ''
  ${pkgs.lib.concatMapStringsSep "\n  " (name: ''
    echo "Checking ${name}..."
    DEBUG=1 SKIP_SUPABASE=1 SKIP_DB=1 ${name}
  '') templateNames}
  touch $out
''

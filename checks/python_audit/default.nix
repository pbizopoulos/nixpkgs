{ inputs, pkgs, ... }:
let
  name = "python_audit";
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.runCommand "check-${name}" { buildInputs = [ package ]; } ''
  DEBUG=1 SKIP_SUPABASE=1 SKIP_DB=1 ${name}
  touch $out
''

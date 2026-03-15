{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  supabase-images = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.runCommand "check-${name}" { } ''
  ls -la ${supabase-images}
  [ -f ${supabase-images}/postgres.tar ]
  touch $out
''

{ inputs, pkgs, ... }:
let
  name = baseNameOf ./.;
  phoenixPackage = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        phoenixPackage
        pkgs.postgresql
      ];
      services.postgresql = {
        enable = true;
        initialScript = pkgs.writeText "init.sql" ''
          CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';
        '';
      };
    };
  testScript = ''
    machine.wait_for_unit("postgresql.service")
    machine.wait_until_succeeds("pg_isready -U postgres")
    # Run the smoke test using the package binary
    # This confirms the app can boot, connect to the DB, and start its supervision tree.
    machine.succeed("DEBUG=1 SKIP_SUPABASE=1 MIX_ENV=prod ${name}")
  '';
}

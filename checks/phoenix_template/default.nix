{ inputs, pkgs, ... }:
pkgs.testers.runNixOSTest rec {
  name = baseNameOf ./.;
  nodes.machine =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.self.packages.${pkgs.stdenv.system}.${name}
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
    machine.succeed("DEBUG=1 ${name}")
  '';
}

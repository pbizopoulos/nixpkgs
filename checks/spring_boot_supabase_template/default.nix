{ inputs, pkgs, ... }:
let
  name = "spring_boot_supabase_template";
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = {
    environment.systemPackages = [ inputs.self.packages.${pkgs.stdenv.system}.${name} ];
  };
  testScript = ''
    machine.succeed("DEBUG=1 ${name}")
  '';
}

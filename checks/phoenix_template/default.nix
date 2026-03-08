{ inputs, pkgs, ... }:
let
  name = baseNameOf ./.;
  phoenixPackage = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine = _: { environment.systemPackages = [ phoenixPackage ]; };
  testScript = ''
    # Run the smoke test using the package binary
    # This confirms the app can boot and start its supervision tree.
    machine.succeed("DEBUG=1 MIX_ENV=prod ${name}")
  '';
}
